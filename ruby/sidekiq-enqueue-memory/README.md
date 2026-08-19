# Sidekiq enqueue memory

Measures how much resident memory a Sidekiq process gains per job it enqueues,
with and without the enqueue instrumentation that version 4.9.0 of the Ruby gem
introduced.

## Why this exists

A customer installed the gem on a Heroku Sidekiq dyno a day after 4.9.0 was
published. The dyno went from a steady 250 megabytes to being killed at over a
gigabyte roughly ninety seconds after every boot, in a loop, and removing the
gem alone put it back to normal. Their logs show about 8.5 megabytes per second
of growth starting from boot, with no jobs completing.

Version 4.9.0 added `enqueue.sidekiq` events, recorded on whichever transaction
is active when a job is enqueued. `SidekiqHook#install` registers the client
middleware on the server as well as the client, so a job that enqueues jobs
records one event per push, and those events sit on a `Vec` in the extension
until the transaction completes. A job that fans out and keeps running therefore
accumulates events without bound, in the Sidekiq process's own memory.

Reading the agent source, one recorded event costs roughly 250 bytes. At that
size the customer's growth rate needs somewhere around 34,000 enqueues per
second to be explained by enqueue events alone, which is high enough to be worth
checking rather than assuming. That is the number this app exists to produce.

## Running it

```bash
rake app=ruby/sidekiq-enqueue-memory app:down app:up
```

Wait for `[worker] AppSignal <version> active in development`, which also prints
whether enqueue instrumentation is on. Then trigger a run:

```bash
curl "http://localhost:4001/fanout?count=200000&batch_size=5000&mode=push_bulk"
```

Or open http://localhost:4001 and use the links. Either way the web page only
queues the job. The measurements come from the Sidekiq process.

The agent logs at trace level in these setups, so the output is noisy. To see
only the numbers, from this directory in another terminal:

```bash
docker compose logs -f app | grep fanout
```

Each checkpoint reports resident memory, growth since the job started, bytes per
enqueue and the growth rate:

```
[fanout] enqueued=5000      rss=112.4MB  growth=1.3MB    bytes_per_enqueue=272    rate=2.1MB/s
```

`bytes_per_enqueue` is the figure that settles the question. `rate` is the one to
compare against the customer's 8.5 megabytes per second.

Note that this pushes to a real app in your AppSignal organization, named
`ruby-sidekiq-enqueue-memory`, using the shared key in `appsignal_key.env`.

## The experiment

Four runs. The first two isolate the config option, the second two isolate the
gem version. Use the same `count` for all of them.

### 1. Enqueue instrumentation on, which is the default

```bash
rake app=ruby/sidekiq-enqueue-memory app:down app:up
```

### 2. Enqueue instrumentation off

```bash
APPSIGNAL_ENABLE_JOB_ENQUEUE_INSTRUMENTATION=false \
  rake app=ruby/sidekiq-enqueue-memory app:down app:up
```

If run 1 grows and run 2 stays flat, the enqueue events are the cause and the
customer has a one line workaround.

### 3 and 4. Before and after the feature landed

The gem is mounted from `ruby/integration`, which is a checkout of
appsignal-ruby, so the version under test is whatever that checkout has at.
Version 4.9.0 is the one the customer ran and 4.8.6 is the release before the
feature existed:

Delete `app/Gemfile.lock` when switching, or bundler keeps resolving the path
gem to the version the lock already names:

```bash
git -C ../integration checkout v4.9.0
rm -f app/Gemfile.lock
rake app=ruby/sidekiq-enqueue-memory app:down app:up

git -C ../integration checkout v4.8.6
rm -f app/Gemfile.lock
rake app=ruby/sidekiq-enqueue-memory app:down app:up
```

`commands/run` prints the version it resolved on boot, so check that line rather
than trusting the checkout.

Put the checkout back when you are done, since other setups share it:

```bash
git -C ../integration checkout main
```

Version 4.9.0 also added automatic Faraday instrumentation. This app makes no
outbound requests, so that feature cannot influence these numbers, which is why
the comparison is clean.

## Results from the first run, 19 August 2026

200,000 jobs pushed with `push_bulk` in batches of 5,000, from inside one
Sidekiq job, on Ruby 3.3.12 and Sidekiq 7.3.10.

| Gem | Enqueue events | Growth | Bytes per enqueue | Elapsed |
| --- | --- | --- | --- | --- |
| 4.9.0 | recorded | 45.4MB | 238 | 5.2s |
| 4.9.0 | suppressed | 5.9MB | 31 | 1.3s |
| 4.8.6 | not available | 6.3MB | 33 | 1.0s |

The enqueue events account for 39.5 of the 45.4 megabytes, and cost roughly
seven times as much memory per enqueue as the enqueue itself. Version 4.8.6 and
version 4.9.0 with the option off are within noise of each other, which is what
confirms the feature is the difference rather than anything else in the release.

Recording the events also made the same fan out about four times slower.

The growth is linear, not a spike. `bytes_per_enqueue` starts near 1,200 while
the Ruby heap warms up and settles onto a flat 238 by the halfway point.

Two caveats on reading across to the customer's dyno. Their growth rate was 8.5
megabytes per second and this run produced 8.7, but only because it sustained
about 38,000 enqueues per second against a Redis container on the same host.
Whether their worker pushed anywhere near that fast is not something these
numbers can answer. And 238 bytes per enqueue means their gigabyte of growth
would need several million enqueues, so a smaller fan out makes this a
contributing cause rather than the whole story.

## Reading the result

- Flat memory in every run means the enqueue path is not the customer's problem
  and the initializer they were asked for becomes the prime suspect.
- Growth that scales with the number of enqueues but needs an unrealistic rate
  to reach 8.5 megabytes per second means this contributes without explaining
  the whole thing.
- Growth at a rate near the customer's means the theory holds and
  `enable_job_enqueue_instrumentation` is the fix to offer them.

Run `/baseline` to see what a long lived transaction costs when it enqueues
nothing, and subtract that before drawing conclusions.

## Knobs

| Parameter | Default | Notes |
| --- | --- | --- |
| `count` | 200000 | Total jobs to enqueue |
| `batch_size` | 5000 | Jobs per `push_bulk`, and the checkpoint interval |
| `mode` | `push_bulk` | `push_bulk` or `perform_async` |

`push_bulk` and `perform_async` are both offered because they reach the client
middleware by different routes. If only one of them grows, that narrows the
problem considerably.

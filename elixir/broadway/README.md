# Broadway example

A [Broadway](https://elixir-broadway.org/) example app, running Broadway 1.3.0.


## The pipeline

`BroadwayExample.Pipeline` sets up this topology:

```
producer (1)
   |
processors (4)   handle_message/3, once per message
   |
:default         batcher, grouping messages into batches
   |
batch procs      handle_batch/4, once per batch
```

- **Producer** — `BroadwayExample.Producer`, a hand-written GenStage producer,
  so the app needs no message broker.
- **Processors** — four concurrent processes running `handle_message/3`.
  Each message is enriched, then tagged with the `:default` batcher and a batch
  key.  Every payment is in EUR, so the batch key is always the same; it is
  there to show where a batcher would split its messages further.
- **Batcher** — `:default` flushes every 10 messages or 2 seconds.
  `handle_batch/4` then handles the whole batch in one go.
- **Acknowledger** — `BroadwayExample.Acknowledger`.  Broadway calls it with the
  successful and failed messages of every batch.  With a real source this is
  where messages get deleted from the queue or requeued.

The status page's counters are kept in `BroadwayExample.Stats`.

The app starts the same pipeline a second time, registered under
`{:via, Registry, {BroadwayExample.Registry, :registered_pipeline}}` rather
than an atom.  Broadway accepts such names from 1.1.0 on, provided the pipeline
names its own processes with `process_name/2`, so their process names are
tuples too.  `/push/registered` sends a payment to that copy.  The counters are
shared between the two.

Before `handle_message/3` runs, `prepare_messages/2` looks up the customers of
every message in a processor call at once.  Both callbacks wrap their work in
`Appsignal.instrument`, so the app's own instrumentation runs inside them.


## The web interface

Broadway has no HTTP surface of its own.  `BroadwayExample.Router` adds one, so
the app has an index page and so bursts of messages can be pushed by hand:

| Route           | What it does                                |
|-----------------|---------------------------------------------|
| `/`             | Status page with the pipeline's counters    |
| `/push`         | 1 payment                                   |
| `/push/failing` | 1 payment that raises in `handle_message/3` |
| `/push/failing_prepare` | 1 payment that raises in `prepare_messages/2` |
| `/push/registered` | 1 payment to the pipeline registered under a `{:via, ...}` name |
| `/push/burst`   | 500 payments at once                        |
| `/topology`     | The running Broadway topology               |
| `/error`        | Raises in the web request                   |


## Generating events

The pipeline is idle until you push something into it.  Use the links on the
index page, or hit the routes directly:

```
curl http://localhost:4001/push
```

`rake app=elixir/broadway app:bot` walks those links on a loop, which is the
easiest way to keep a steady stream of traffic going.

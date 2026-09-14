# Broadway example

A [Broadway](https://elixir-broadway.org/) example app, running Broadway 1.3.0.


## The pipeline

`BroadwayExample.Pipeline` sets up this topology:

```
producer (1)
   |
processors (2)            handle_message/3, once per message
   |          \
:default    :suspicious   batchers, grouping messages into batches
   |             |
batch procs   batch procs handle_batch/4, once per batch
```

- **Producer** — `BroadwayExample.Producer`, a hand-written GenStage producer,
  so the app needs no message broker.
- **Processors** — two concurrent processes running `handle_message/3`.
  Each message is enriched, then tagged with a batcher (`:default`, or
  `:suspicious` for payments of 2000.00 or more) and a batch key (the currency).
- **Batchers** — `:default` flushes every 10 messages or 2 seconds,
  `:suspicious` every 3 messages or 5 seconds. `handle_batch/4` then handles the
  whole batch in one go.
- **Acknowledger** — `BroadwayExample.Acknowledger`.  Broadway calls it with the
  successful and failed messages of every batch.  With a real source this is
  where messages get deleted from the queue or requeued.

The status page's counters are kept in `BroadwayExample.Stats`.

There is no monitoring in this app yet.  Adding an AppSignal integration for
Broadway is a separate, later step.


## The web interface

Broadway has no HTTP surface of its own.  `BroadwayExample.Router` adds one, so
the app has an index page and so bursts of messages can be pushed by hand:

| Route              | What it does                                       |
|--------------------|----------------------------------------------------|
| `/`                | Status page with the pipeline's counters           |
| `/push`            | 50 random payments                                 |
| `/push/slow`       | 5 payments that take a while in `handle_message/3` |
| `/push/suspicious` | 6 payments routed to the `:suspicious` batcher     |
| `/push/failing`    | 3 payments that raise in `handle_message/3`        |
| `/push/burst`      | 500 payments at once                               |
| `/topology`        | The running Broadway topology                      |
| `/slow`            | A slow web request                                 |
| `/error`           | Raises in the web request                          |


## Generating events

The pipeline is idle until you push something into it.  Use the links on the
index page, or hit the routes directly:

```
curl http://localhost:4001/push
```

`rake app=elixir/broadway app:bot` walks those links on a loop, which is the
easiest way to keep a steady stream of traffic going.

import Config

config :broadway_example,
  # How often the producer emits a batch of events on its own, in milliseconds.
  # Set to 0 to disable the automatic trickle and only push messages from the
  # web interface.
  tick_interval: String.to_integer(System.get_env("TICK_INTERVAL", "2000")),
  # How many events the producer enqueues on every tick.
  events_per_tick: String.to_integer(System.get_env("EVENTS_PER_TICK", "5"))

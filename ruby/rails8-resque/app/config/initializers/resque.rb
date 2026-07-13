require "resque"

Resque.redis = ENV.fetch("REDIS_URL", "redis://redis:6379")

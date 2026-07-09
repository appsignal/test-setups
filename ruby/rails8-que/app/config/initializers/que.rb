require "que"

# Use Active Record's connection pool for enqueuing and working jobs.
Que.connection = ActiveRecord if defined?(ActiveRecord)

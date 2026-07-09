require "resque/tasks"

namespace :resque do
  # `resque:work` runs this first. Loading the Rails environment makes the job
  # classes available and runs the initializer that points Resque at Redis.
  # Default to the `default` queue (not `*`) so this app's worker does not drain
  # the `downstream` queue, which the separately-instrumented downstream service
  # owns (it exports QUEUE=downstream to override this default).
  task :setup => :environment do
    ENV["QUEUE"] ||= "default"
  end
end

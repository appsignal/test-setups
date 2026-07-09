require "resque/tasks"

namespace :resque do
  # `resque:work` runs this first. Loading the Rails environment makes the job
  # classes available and runs the initializer that points Resque at Redis.
  # Default to working every queue so `rake resque:work` needs no arguments.
  task :setup => :environment do
    ENV["QUEUE"] ||= "*"
  end
end

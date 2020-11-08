require 'fileutils'

def get_app
  ENV['app'].tap do |app|
    raise "Specify which app you want to run using app=path" if app.nil?
    raise "#{app} not found" unless File.exists?(app)
  end
end

def run_command(command)
  puts "Running '#{command}'"
  system command
end

namespace :app do
  desc "Start a test app"
  task :up do
    app = get_app
    puts "Starting #{app}"

    puts "Building..."
    run_command "cd #{app} && docker build -t #{app}  ."

    puts "Starting compose..."
    run_command "cd #{app} && docker-compose up"
  end

  desc "Attach to app and get bash"
  task :bash do
    app = get_app
    puts "Starting bash in #{app}"
    run_command "cd #{app} && docker-compose exec app /bin/bash"
  end

  desc "Attach to app and get a console"
  task :console do
    app = get_app
    puts "Starting console in #{app}"
    run_command "cd #{app} && docker-compose exec app /commands/console.sh"
  end

  desc "Very that test setup works"
  task :verify do
    raise "Not implemented yet"
  end
end

namespace :setup do
  desc "Clone integrations"
  task 
end

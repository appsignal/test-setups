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

namespace :integrations do
  desc "Clone integrations"
  task :clone do
    ["ruby", "elixir"].each do |integration|
      path = "#{integration}/integration"
      if File.exists?(path)
        puts "#{path} already present"
      else
        puts "Cloning #{integration}"
        run_command "git clone git@github.com:appsignal/appsignal-#{integration}.git #{path}"
      end
    end
  end
end

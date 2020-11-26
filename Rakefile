require 'erb'
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

def render_erb(file)
  ERB.new(File.read(file)).result
end

namespace :app do
  desc "Create a test setup skeleton"
  task :new do
    @app = ENV['app']
    raise "#{@app} already exists" if File.exists?(@app)

    # Create directories
    FileUtils.mkdir_p "#{@app}"
    FileUtils.mkdir_p "#{@app}/commands"
    FileUtils.mkdir_p "#{@app}/working_directory"
    FileUtils.touch "#{@app}/working_directory/.gitkeep"

    # Copy command scripts
    %w(boot console).each do |command|
      FileUtils.cp "support/template/commands/#{command}.sh", "#{@app}/commands/#{command}.sh"
    end

    # Copy Dockerfile
    FileUtils.cp "support/template/Dockerfile", "#{@app}/Dockerfile"

    # Render docker compose file
    File.write "#{@app}/docker-compose.yml", render_erb("support/template/docker-compose.yml.erb")

    # Render env file
    File.write "#{@app}/appsignal.env", render_erb("support/template/appsignal.env.erb")

    puts "Generated test setup skeleton in #{@app}, add your code in app directory now"
  end

  desc "Start a test app"
  task :up do
    @app = get_app
    puts "Starting #{@app}"

    puts "Building..."
    run_command "cd #{@app} && docker build -t #{@app}  ."

    puts "Starting compose..."
    run_command "cd #{@app} && docker-compose up"
  end

  desc "Attach to app and get bash"
  task :bash do
    @app = get_app
    puts "Starting bash in #{@app}"
    run_command "cd #{@app} && docker-compose exec app /bin/bash"
  end

  desc "Attach to app and get a console"
  task :console do
    @app = get_app
    if File.exists?("#{@app}/commands/console.sh")
      puts "Starting console in #{@app}"
      run_command "cd #{@app} && docker-compose exec app /commands/console.sh"
    else
      puts "Starting a console in #{@app} is not supported"
    end
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

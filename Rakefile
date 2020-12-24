require 'erb'
require 'fileutils'

LANGUAGES = %w(elixir ruby)

def get_app
  ENV['app'].tap do |app|
    raise "Specify which app you want to run using app=path" if app.nil?
    raise "#{app} not found" unless File.exists?(app)
  end
end

def clone_from_git(path, repo)
  if File.exists?(path)
    puts "#{path} already present"
  else
    puts "Cloning #{repo} into #{path}"
    run_command "git clone git@github.com:appsignal/#{repo}.git #{path}"
  end
end

def reset_repo(path)
  if File.exists?(path)
    puts "Resetting #{integration}"
    run_command "cd #{path} && git fetch && git reset --hard origin/main"
  else
    puts "#{path} not present"
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
  desc "Open the browser pointing to the app"
  task :open do
    run_command "open http://localhost:3000"
  end

  desc "Create a test setup skeleton"
  task :new do
    @app = ENV['app']
    raise "#{@app} already exists" if File.exists?(@app)

    # Create directories
    FileUtils.mkdir_p "#{@app}"
    FileUtils.mkdir_p "#{@app}/commands"

    # Copy command scripts
    %w(boot console).each do |command|
      FileUtils.cp "support/templates/skeleton/commands/#{command}.sh", "#{@app}/commands/#{command}.sh"
    end

    # Copy Dockerfile
    FileUtils.cp "support/templates/skeleton/Dockerfile", "#{@app}/Dockerfile"

    # Copy readme
    FileUtils.cp "support/templates/skeleton/README.md", "#{@app}/README.md"

    # Render docker compose file
    File.write "#{@app}/docker-compose.yml", render_erb("support/templates/skeleton/docker-compose.yml.erb")

    puts "Generated test setup skeleton in #{@app}, add your code in app directory now"
  end

  desc "Start a test app"
  task :up do
    unless File.exist?("appsignal_key.env")
      raise "Please copy appsignal_key.env.example to appsignal_key.env and add a push api key"
    end

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

  desc "Remove docker images"
  task :down do
      @app = get_app
      puts "Bringing compose down..."
      run_command "cd #{@app} && docker-compose down --rmi=local"
  end

  namespace :tail do
    desc "Tail appsignal.log"
    task :appsignal do
      @app = get_app
      run_command "cd #{@app} && docker-compose exec app tail -f /tmp/appsignal.log"
    end
  end
end

namespace :integrations do
  desc "Clone integrations"
  task :clone do
    # Clone Ruby
    clone_from_git("ruby/integration", "appsignal-ruby")
    # Clone Elixir, it currently consists of multiple repos
    FileUtils.mkdir_p("elixir/integration")
    clone_from_git("elixir/integration/appsignal-elixir", "appsignal-elixir")
    clone_from_git("elixir/integration/appsignal-elixir-phoenix", "appsignal-elixir-phoenix")
    clone_from_git("elixir/integration/appsignal-elixir-plug", "appsignal-elixir-plug")
  end

  desc "Reset integrations"
  task :reset do
    reset_repo("ruby/integration")
    reset_repo("elixir/integration/appsignal-elixir-phoenix")
    reset_repo("elixir/integration/appsignal-phoenix")
    reset_repo("elixir/integration/appsignal-plug")
  end

  desc "Remove integrations"
  task :clean do
    run_command("rm -rf ruby/integration")
    run_command("rm -rf elixir/integration")
  end
end

namespace :global do
  desc "Update global files"
  task :update => [:update_readme]

  desc "Update the readme using the template"
  task :update_readme do
    @apps = LANGUAGES.map do |language|
      Dir["#{language}/*"].reject do |dir|
        dir.end_with?("integration")
      end
    end.flatten

    File.write "README.md", render_erb("support/templates/README.md.erb")
  end
end

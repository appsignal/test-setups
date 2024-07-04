require 'erb'
require 'fileutils'

LANGUAGES = %w(elixir ruby nodejs javascript)
PROCESSMON_PATH = "support/processmon/processmon"

def get_app
  ENV['app'].tap do |app|
    raise "Specify which app you want to run using app=path" if app.nil?
    raise "#{app} not found" unless File.exist?(app)
  end.delete_suffix("/")
end

def clone_from_git(path, repo)
  if File.exist?(path)
    puts "#{path} already present"
    reset_repo(path)
  else
    puts "Cloning #{repo} into #{path}"
    run_command "git clone git@github.com:appsignal/#{repo}.git #{path}"
  end
end

def reset_repo(path, branch: "main")
  if File.exist?(path)
    puts "Resetting #{path}"
    run_command "cd #{path} && git fetch origin"
    run_command "cd #{path} && git switch -f #{branch}"
    run_command "cd #{path} && git reset --hard origin/#{branch}"
    run_command "cd #{path} && git clean -dfx ."
  else
    puts "#{path} not present"
  end
end

def run_command(command)
  puts "Running '#{command}'"
  # Spawn child process with parent process STDIN, STDOUT and STDERR
  pid = spawn({}, command, :in => $stdin, :out => $stdout, :err => $stderr)
  # Register child process so we can wait for it to exit gracefully later
  child_processes << [pid, command]
  # Wait for child process to end
  _pid, status = Process.wait2(pid)
  # Exit with the error status code if an error occurred in the child process
  exit status.exitstatus unless status.success?
end

def child_processes
  @child_processes ||= []
end

# "Trap" an interrupt from the user and wait for the child processes to end
# first before exiting this process. Docker-compose if interrupted gracefully
# stops all its containers first before truely exiting, wait for this graceful
# exit.
Signal.trap "INT" do
  return if child_processes.empty?

  child_processes.each do |(pid, command)|
    begin
      Process.kill(0, pid) # Check if process still exists

      puts "Waiting for child process to end: #{pid}: #{command}"
      _pid, status = Process.wait2(pid)
      # Exit with the error status code if an error occurred in the child process
      exit status.exitstatus unless status.success?
    rescue Errno::ESRCH
      # Do nothing, child process is no longer running
    end
  end
  # There were no errors, so gracefully exit process here
  exit 0
end

def render_erb(file)
  ERB.new(File.read(file)).result
end

namespace :app do
  desc "Open the browser pointing to the app"
  task :open do
    run_command "open http://localhost:4001"
  end

  desc "Create a test setup skeleton"
  task :new do
    @app = ENV['app']
    raise "#{@app} already exists" if File.exist?(@app)

    # Create directories
    FileUtils.mkdir_p "#{@app}"
    FileUtils.mkdir_p "#{@app}/app"
    FileUtils.mkdir_p "#{@app}/commands"

    # Copy command scripts
    %w(console diagnose demo run).each do |command|
      FileUtils.cp "support/templates/skeleton/commands/#{command}", "#{@app}/commands/#{command}"
    end

    # Copy readme
    FileUtils.cp "support/templates/skeleton/README.md", "#{@app}/README.md"

    # Render Dockerfile
    File.write "#{@app}/Dockerfile", render_erb("support/templates/skeleton/Dockerfile.erb")

    # Render docker compose file
    File.write "#{@app}/docker-compose.yml", render_erb("support/templates/skeleton/docker-compose.yml.erb")

    puts "Generated test setup skeleton in #{@app}. Next:"
    puts "- Add your code in the app directory"
    puts "- Fill out the TODO markers in the generated files"
  end

  def build_app
    unless File.exist?("appsignal_key.env")
      raise "No push api key set yet, run rake global:set_push_api_key key=<key>"
    end
    unless File.exist?(PROCESSMON_PATH)
      puts "Processmon not present. Building processmon..."
      Rake::Task["global:install_processmon"].invoke
    end

    @app = get_app
    puts "Starting #{@app}"

    puts "Copying processmon"
    FileUtils.rm_f "#{@app}/commands/processmon"
    FileUtils.cp "support/processmon/processmon", "#{@app}/commands/"

    run_hook @app, :before_build

    puts "Building environment..."
    options = ""
    build_args = ENV["build_arg"]
    if build_args
      options = "--build-arg=#{build_args}"
    end
    run_command "cd #{@app} && docker-compose build #{options}"

    puts "Cleaning processmon"
    FileUtils.rm_f "#{@app}/commands/processmon"
  end

  desc "Start a test app"
  task :up do
    build_app

    puts "Starting compose..."
    run_command "cd #{@app} && docker-compose up --abort-on-container-exit"
  end

  desc "Start a test app and run the tests on it"
  task :test do
    build_app

    puts "Building the tests container..."
    run_command "cd #{@app} && docker-compose build --build-arg TESTING=true tests"

    puts "Starting compose with the tests..."
    run_command "cd #{@app} && docker-compose --profile tests up --abort-on-container-exit --exit-code-from tests"
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
    if File.exist?("#{@app}/commands/console")
      puts "Starting console in #{@app}"
      run_command "cd #{@app} && docker-compose exec app /commands/console"
    else
      puts "Starting a console in #{@app} is not supported"
    end
  end

  desc "Attach to app and run diagnose"
  task :diagnose do
    @app = get_app
    if File.exist?("#{@app}/commands/diagnose")
      puts "Runing diagnose in #{@app}"
      run_command "cd #{@app} && docker-compose exec app /commands/diagnose"
    else
      puts "Running diagnose in #{@app} is not supported"
    end
  end

  desc "Attach to app and run demo"
  task :demo do
    @app = get_app
    if File.exist?("#{@app}/commands/demo")
      puts "Runing demo in #{@app}"
      run_command "cd #{@app} && docker-compose exec app /commands/demo"
    else
      puts "Running demo in #{@app} is not supported"
    end
  end

  desc "Restart the app container, needed when making changes in the integration"
  task :restart do
    @app = get_app
    puts "Restarting #{@app}"
    run_command "cd #{@app} && docker-compose restart app"
  end

  desc "Bring compose down and remove cached app docker image"
  task :down do
    @app = get_app
    puts "Bringing compose down..."
    run_command "cd #{@app} && docker-compose --profile tests down --rmi=local"
    run_command "docker image rm -f #{@app}:latest"
  end

  namespace :tail do
    desc "Tail appsignal.log"
    task :appsignal do
      @app = get_app
      run_command "cd #{@app} && docker-compose exec app touch /tmp/appsignal.log"
      run_command "cd #{@app} && docker-compose exec app tail -f /tmp/appsignal.log"
    end
  end

  namespace :less do
    desc "Less +F appsignal.log"
    task :appsignal do
      @app = get_app
      run_command "cd #{@app} && docker-compose exec app touch /tmp/appsignal.log"
      run_command "cd #{@app} && docker-compose exec app less +F /tmp/appsignal.log"
    end
  end
end

namespace :integrations do
  desc "Clone and reset integrations"
  task :clone do
    # Clone Ruby
    clone_from_git("ruby/integration", "appsignal-ruby")
    # Clone Elixir, it currently consists of multiple repos
    FileUtils.mkdir_p("elixir/integration")
    clone_from_git("elixir/integration/appsignal-elixir", "appsignal-elixir")
    clone_from_git("elixir/integration/appsignal-elixir-phoenix", "appsignal-elixir-phoenix")
    clone_from_git("elixir/integration/appsignal-elixir-plug", "appsignal-elixir-plug")
    # Clone Node.js
    clone_from_git("nodejs/integration", "appsignal-nodejs")
    # Clone JavaScript
    clone_from_git("javascript/integration", "appsignal-javascript")
    # Clone Python
    clone_from_git("python/integration", "appsignal-python")
  end

  desc "Remove integrations"
  task :clean do
    run_command("rm -rf ruby/integration")
    run_command("rm -rf elixir/integration")
    run_command("rm -rf nodejs/integration")
    run_command("rm -rf javascript/integration")
    run_command("rm -rf python/integration")
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
      end.sort
    end.flatten

    File.write "README.md", render_erb("support/templates/README.md.erb")
  end

  desc "Set the push api key to use"
  task :set_push_api_key do
    @key = ENV['key'] or raise "No key provided"
    puts "Setting push api key in appsignal_key.env"
    File.write "appsignal_key.env", render_erb("support/templates/appsignal_key.env.erb")
  end

  desc "Install bundled processmon"
  task :install_processmon do
    run_command("cd support/processmon && ./build.sh")
  end
end

def run_hook(app, event)
  if event == :before_build
    hook_file = "hooks/#{event}"
    hook_file_path = File.join(@app, hook_file)
    return unless File.exist? hook_file_path

    run_command("cd #{@app} && ./#{hook_file}")
  end
end

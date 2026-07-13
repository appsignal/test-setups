require 'erb'
require 'fileutils'

LANGUAGES = %w(elixir go java javascript nodejs php python ruby standalone vector)
PROCESSMON_PATH = "support/processmon/processmon"

# The active environment file every test setup reads. It's written by
# `env:switch` from a per-environment `appsignal_key.<name>.env` file, with an
# `# ENV: <name>` marker line prepended so the active environment is visible in
# the file itself (it's also printed on boot).
ACTIVE_KEY_FILE = "appsignal_key.env"

def get_app
  ENV['app'].tap do |app|
    raise "Specify which app you want to run using app=path" if app.nil?
    raise "#{app} not found" unless File.exist?(app)
  end.delete_suffix("/")
end

# The environment name from the `env=` parameter, e.g. `prod` for
# `appsignal_key.prod.env`.
def get_env
  ENV['env'].tap do |name|
    raise "Specify which environment you want using env=<name>" if name.nil? || name.strip.empty?
  end.strip
end

# The per-environment key file that `env=<name>` selects.
def env_key_file(name)
  "appsignal_key.#{name}.env"
end

# A committed default for an environment, copied into the per-environment file
# the first time you switch to it. `local` and `staging` ship one; other
# environments start from whatever key you pass.
def default_env_file(name)
  "#{env_key_file(name)}.example"
end

# Set the push api key in a key file, replacing an existing
# `APPSIGNAL_PUSH_API_KEY` line if present and leaving the rest of the file
# (endpoints and so on) untouched. Creates the file if it doesn't exist.
def set_push_api_key(file, key)
  var = "APPSIGNAL_PUSH_API_KEY"
  lines = File.exist?(file) ? File.readlines(file, :chomp => true) : []
  replaced = false
  lines.map! do |line|
    next line unless line.start_with?("#{var}=")
    replaced = true
    "#{var}=#{key}"
  end
  lines << "#{var}=#{key}" unless replaced
  File.write file, lines.join("\n") + "\n"
end

# Make `name` the active environment: seed its key file from the committed
# default if needed, set the key when one is given, then copy it into
# `appsignal_key.env` with an `# ENV: <name>` marker.
def switch_env(name, key = nil)
  source = env_key_file(name)

  if !File.exist?(source) && File.exist?(default_env_file(name))
    puts "Creating #{source} from #{default_env_file(name)}"
    FileUtils.cp default_env_file(name), source
  end

  set_push_api_key(source, key) if key

  unless File.exist?(source)
    raise "No #{source} found. Provide a key to create it, e.g. rake env=#{name} key=<key> env:switch"
  end

  File.write ACTIVE_KEY_FILE, "# ENV: #{name}\n#{File.read(source)}"
  puts "Switched active environment to '#{name}'."
end

# A mode is just a `docker-compose.<mode>.yml` file in the app directory. The
# `shared` file is reserved (it holds the common services every mode includes)
# and is never a selectable mode. Returns a `{ mode_name => filename }` map.
def mode_files(app)
  Dir["#{app}/docker-compose.*.yml"].each_with_object({}) do |path, files|
    mode = File.basename(path).sub(/\Adocker-compose\./, "").sub(/\.yml\z/, "")
    next if mode == "shared"
    files[mode] = File.basename(path)
  end
end

# A plain `docker-compose.yml` provides the `default` mode (so does an explicit
# `docker-compose.default.yml`).
def has_plain_default?(app)
  File.exist?("#{app}/docker-compose.yml")
end

# The modes an app can run in, for listing and validation.
def available_modes(app)
  modes = mode_files(app).keys
  modes << "default" if has_plain_default?(app) && !modes.include?("default")
  modes
end

# The compose file that defines an app in the given mode. Each per-mode file
# includes the app's `docker-compose.shared.yml`, so loading one is enough.
def compose_file_for(app, mode)
  files = mode_files(app)
  return files[mode] if files.key?(mode)
  return "docker-compose.yml" if mode == "default" && has_plain_default?(app)
  raise "App #{app} has no compose file for '#{mode}' mode."
end

def compose_file_arg(app, mode)
  "-f #{compose_file_for(app, mode)}"
end

# Resolve the mode for an app from the `mode=` parameter:
# - no mode given: the `default` mode if present, else `agent`, else error.
# - `mode=shared`: error (reserved, not selectable).
# - mode given but not available for the app: error, listing what is available.
# - the `default` mode is ambiguous when both `docker-compose.yml` and
#   `docker-compose.default.yml` exist: error.
# The chosen mode is printed so it's clear at the start of the output.
def get_mode(app)
  files = mode_files(app)
  available = available_modes(app)
  default_conflict = has_plain_default?(app) && files.key?("default")
  requested = ENV["mode"]
  requested = nil if requested && requested.strip.empty?

  mode =
    if requested.nil?
      if available.include?("default")
        "default"
      elsif available.include?("agent")
        "agent"
      else
        raise "No mode specified for #{app} and it has no default or agent mode. Available modes: #{available.sort.join(", ")}."
      end
    elsif requested == "shared"
      raise "'shared' is not a selectable mode; it holds the services shared by every mode."
    elsif !available.include?(requested)
      raise "App #{app} does not support '#{requested}' mode. Available modes: #{available.sort.join(", ")}."
    else
      requested
    end

  if mode == "default" && default_conflict
    raise "App #{app} has both docker-compose.yml and docker-compose.default.yml, which both define the 'default' mode. Remove one."
  end

  puts "==> Mode: #{mode}"
  mode
end

def clone_from_git(path, repo, branch: nil)
  if File.exist?(path)
    puts "#{path} already present"
    reset_repo(path, :branch => branch)
  else
    puts "Cloning #{repo} into #{path}"
    branch_arg = "--branch #{branch}" if branch
    repo_location =
      if ENV["RUNNING_IN_CI"]
        # Download using HTTPS on CI because it has no SSH authentication configured
        "https://github.com/appsignal/#{repo}.git"
      else
        "git@github.com:appsignal/#{repo}.git"
      end
    run_command "git clone #{branch_arg} #{repo_location} #{path}"
    puts "Cloned #{repo} at #{path} is at commit #{`cd #{path} && git rev-parse HEAD`.strip}"
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

class FailedCommand < StandardError
  def initialize(cmd, exitcode)
    @messsage = "The command '#{cmd}' failed with '#{exitcode}' exit code"
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
  raise FailedCommand.new(command, status.exitstatus) unless status.success?
end

def child_processes
  @child_processes ||= []
end

# "Trap" an interrupt from the user and wait for the child processes to end
# first before exiting this process. Docker compose if interrupted gracefully
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

namespace :env do
  desc "Switch the active environment, e.g. rake env=prod env:switch (pass key=<key> to also set its key)"
  task :switch do
    switch_env(get_env, ENV['key'])
  end

  desc "Switch to the local environment (pass key=<key> to also set its key)"
  task :local do
    switch_env("local", ENV['key'])
  end

  desc "Switch to the staging environment (pass key=<key> to also set its key)"
  task :staging do
    switch_env("staging", ENV['key'])
  end

  desc "Switch to the production environment (pass key=<key> to also set its key)"
  task :prod do
    switch_env("prod", ENV['key'])
  end
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
    %w(console diagnose prepare run).each do |command|
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
    unless File.exist?(ACTIVE_KEY_FILE)
      raise "No active environment set yet, run e.g. rake env:local or rake env=<name> key=<key> env:switch"
    end
    unless File.exist?(PROCESSMON_PATH)
      puts "Processmon not present. Building processmon..."
      Rake::Task["global:install_processmon"].invoke
    end

    @app = get_app
    @mode = get_mode(@app)
    puts "Starting #{@app}"

    puts "=" * 50
    puts File.read(ACTIVE_KEY_FILE)
    puts "=" * 50

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
    run_command "cd #{@app} && docker compose #{compose_file_arg(@app, @mode)} build #{options}"

    puts "Cleaning processmon"
    FileUtils.rm_f "#{@app}/commands/processmon"
  end

  desc "Start a test app"
  task :up do
    build_app

    puts "Starting compose..."
    run_command "cd #{@app} && docker compose #{compose_file_arg(@app, @mode)} up --abort-on-container-exit"
  end

  desc "Start a test app and run the tests on it"
  task :test do
    build_app

    puts "Building the tests container..."
    run_command "cd #{@app} && docker compose #{compose_file_arg(@app, @mode)} build --build-arg TESTING=true tests"

    puts "Starting compose with the tests..."
    run_command "cd #{@app} && docker compose #{compose_file_arg(@app, @mode)} --profile tests up --abort-on-container-exit --exit-code-from tests"
  end

  desc "Start a test app with the bot generating activity"
  task :bot do
    build_app

    puts "Building the bot container..."
    run_command "cd #{@app} && docker compose #{compose_file_arg(@app, @mode)} build bot"

    puts "Starting compose with the bot..."
    run_command "cd #{@app} && docker compose #{compose_file_arg(@app, @mode)} --profile bot up --abort-on-container-exit"
  end

  desc "Attach to app and get bash"
  task :bash do
    @app = get_app
    @mode = get_mode(@app)
    puts "Starting bash in #{@app}"
    workdir =
      if @app.start_with?("php/")
        "/var/www/html"
      else
        "/app"
      end
    run_command "cd #{@app} && docker compose #{compose_file_arg(@app, @mode)} exec --workdir #{workdir} app /bin/bash"
  rescue FailedCommand
    puts "Failed to open '#{workdir}' working directory. Does it exist?"
    puts
    puts "Starting bash in #{@app} in root '/' fallback directory"
    run_command "cd #{@app} && docker compose #{compose_file_arg(@app, @mode)} exec --workdir / app /bin/bash"
  end

  desc "Attach to app and get a console"
  task :console do
    @app = get_app
    @mode = get_mode(@app)
    if File.exist?("#{@app}/commands/console")
      puts "Starting console in #{@app}"
      run_command "cd #{@app} && docker compose #{compose_file_arg(@app, @mode)} exec app /commands/console"
    else
      puts "Starting a console in #{@app} is not supported"
    end
  end

  desc "Attach to app and run diagnose"
  task :diagnose do
    @app = get_app
    @mode = get_mode(@app)
    if File.exist?("#{@app}/commands/diagnose")
      puts "Runing diagnose in #{@app}"
      run_command "cd #{@app} && docker compose #{compose_file_arg(@app, @mode)} exec app /commands/diagnose"
    else
      puts "Running diagnose in #{@app} is not supported"
    end
  end

  desc "Attach to app and run demo"
  task :demo do
    @app = get_app
    @mode = get_mode(@app)
    if File.exist?("#{@app}/commands/demo")
      puts "Runing demo in #{@app}"
      run_command "cd #{@app} && docker compose #{compose_file_arg(@app, @mode)} exec app /commands/demo"
    else
      puts "Running demo in #{@app} is not supported"
    end
  end

  desc "Restart the app container, needed when making changes in the integration"
  task :restart do
    @app = get_app
    @mode = get_mode(@app)
    puts "Restarting #{@app}"
    run_command "cd #{@app} && docker compose #{compose_file_arg(@app, @mode)} restart app"
  end

  desc "Bring compose down and remove cached app docker image"
  task :down do
    @app = get_app
    # Tear everything down with the most complete compose file. The collector
    # file includes the shared file plus the collector service, so it knows
    # about every container; fall back to the default/agent file otherwise.
    files = mode_files(@app)
    down_file =
      files["collector"] ||
      (has_plain_default?(@app) ? "docker-compose.yml" : nil) ||
      files["default"] ||
      files["agent"] ||
      files.values.first
    puts "Bringing compose down..."
    run_command "cd #{@app} && docker compose -f #{down_file} --profile tests --profile bot down --rmi=local"
    run_command "docker image rm -f #{@app}:latest"
  end

  namespace :tail do
    desc "Tail appsignal.log"
    task :appsignal do
      @app = get_app
      @mode = get_mode(@app)
      run_command "cd #{@app} && docker compose #{compose_file_arg(@app, @mode)} exec app sh -c 'touch /tmp/appsignal.log && tail -f /tmp/appsignal.log'"
    end
  end

  namespace :head do
    desc "Head appsignal.log (first 20 lines)"
    task :appsignal do
      @app = get_app
      @mode = get_mode(@app)
      run_command "cd #{@app} && docker compose #{compose_file_arg(@app, @mode)} exec app sh -c 'touch /tmp/appsignal.log && tail -f -n +1 /tmp/appsignal.log | head -n 20'"
    end
  end

  namespace :less do
    desc "Less +F appsignal.log"
    task :appsignal do
      @app = get_app
      @mode = get_mode(@app)
      run_command "cd #{@app} && docker compose #{compose_file_arg(@app, @mode)} exec app touch /tmp/appsignal.log"
      run_command "cd #{@app} && docker compose #{compose_file_arg(@app, @mode)} exec app less +F /tmp/appsignal.log"
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
    # Clone PHP
    clone_from_git("php/integration", "appsignal-php")
  end

  desc "Remove integrations"
  task :clean do
    run_command("rm -rf ruby/integration")
    run_command("rm -rf elixir/integration")
    run_command("rm -rf nodejs/integration")
    run_command("rm -rf javascript/integration")
    run_command("rm -rf python/integration")
    run_command("rm -rf php/integration")
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

    # The bot service is pulled in via the bot compose include, which may live
    # in the app's mode files or in its `docker-compose.shared.yml`.
    @bot_apps = @apps.select do |app|
      %w(docker-compose.yml docker-compose.agent.yml docker-compose.shared.yml).any? do |file|
        path = "#{app}/#{file}"
        File.exist?(path) && File.read(path).include?("support/bot/docker-compose.yml")
      end
    end

    # Apps that ship a collector compose file can be run in collector mode.
    @collector_apps = @apps.select do |app|
      mode_files(app).key?("collector")
    end

    File.write "README.md", render_erb("support/templates/README.md.erb")
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

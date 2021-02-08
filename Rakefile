require 'erb'
require 'fileutils'

LANGUAGES = %w(elixir ruby nodejs javascript)

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

def reset_repo(path, branch: "main")
  if File.exists?(path)
    puts "Resetting #{path}"
    run_command "cd #{path} && git fetch origin"
    run_command "cd #{path} && git switch #{branch}"
    run_command "cd #{path} && git reset --hard origin/#{branch}"
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
    raise "#{@app} already exists" if File.exists?(@app)

    # Create directories
    FileUtils.mkdir_p "#{@app}"
    FileUtils.mkdir_p "#{@app}/app"
    FileUtils.mkdir_p "#{@app}/commands"

    # Copy command scripts
    %w(boot console diagnose).each do |command|
      FileUtils.cp "support/templates/skeleton/commands/#{command}.sh", "#{@app}/commands/#{command}.sh"
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

  desc "Start a test app"
  task :up => :prepare_nfs do
    unless File.exist?("appsignal_key.env")
      raise "No push api key set yet, run rake global:set_push_api_key key=<key>"
    end

    @app = get_app
    puts "Starting #{@app}"

    puts "Building environment..."
    run_command "cd #{@app} && docker-compose build"

    puts "Starting compose..."
    run_command "cd #{@app} && docker-compose up --abort-on-container-exit"
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

  desc "Attach to app and run diagnose"
  task :diagnose do
    @app = get_app
    if File.exists?("#{@app}/commands/diagnose.sh")
      puts "Runing diagnose in #{@app}"
      run_command "cd #{@app} && docker-compose exec app /commands/diagnose.sh"
    else
      puts "Running diagnose in #{@app} is not supported"
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
    run_command "cd #{@app} && docker-compose down --rmi=local"
    run_command "docker image rm -f #{@app}:latest"
  end

  namespace :tail do
    desc "Tail appsignal.log"
    task :appsignal do
      @app = get_app
      run_command "cd #{@app} && docker-compose exec app tail -f /tmp/appsignal.log"
    end
  end

  task :prepare_nfs do
    require "rbconfig"
    unless RbConfig::CONFIG["host_os"].downcase.start_with? "darwin"
      puts "Warning: Skipping NFS check. Host system is not macOS. Use at own risk."
    end

    exports_path = "/etc/exports"
    exports = File.read(exports_path)
    required_exports = %(/Users -alldirs -mapall=#{Process.uid}:#{Process.gid} localhost)
    exports_missing = false
    exports_missing = true unless exports.include?(required_exports)

    nfs_config_path = "/etc/nfs.conf"
    nfs_config = File.read(nfs_config_path)
    required_nfs_config = "nfs.server.mount.require_resv_port = 0"
    nfs_config_missing = false
    nfs_config_missing = true unless nfs_config.include?(required_nfs_config)

    if exports_missing || nfs_config_missing
      puts "Warning: Some system config is missing for NFS volumes support."
      puts "We will need to shut down all Docker setups (docker-compose down) and restart Docker."
      puts "Please make sure you have stopped any running containers before continuing."
      puts "Press `y` to continue. Press any other key to exit."
      print "Continue? "
      input = $stdin.gets.chomp
      if input == "y"
        puts "Configuring NFS volumes on the system."
        puts "Stopping all apps."
        Dir["{#{LANGUAGES.join(",")}}/*"].each do |dir|
          next if dir.end_with?("integration")

          puts "Running: `docker-compose down` for `#{dir}`"
          `cd #{dir} && docker-compose down`
        end

        puts "Stopping Docker."
        `osascript -e 'quit app "Docker"'`
      else
        puts "Exiting without configuring NFS volumes."
        exit 1
      end
    else
      next # Config correct, skipping
    end

    if exports_missing
      puts
      puts "Warning: Exports not set up"
      puts "Setting exports for NFS volumes."
      puts "This may prompt for your password and prompt a macOS security confirmation."
      puts
      `echo #{required_exports} | sudo tee -a #{exports_path}`
    end

    if nfs_config_missing
      puts
      puts "Warning: NFS not set up"
      puts "Configuring NFS volumes."
      puts "This may prompt for your password and prompt a macOS security confirmation."
      puts
      `echo #{required_nfs_config} | sudo tee -a #{nfs_config_path}`
    end

    puts
    puts "Restarting NFS. This may prompt for your password."
    `sudo nfsd restart`

    puts
    puts "Starting Docker."
    `open -a Docker`

    puts
    puts "Configuration done. Now continuing."
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
    # Clone Node.js
    clone_from_git("nodejs/integration", "appsignal-nodejs")
    reset_repo("nodejs/integration", branch: "make")
    # Clone JavaScript
    clone_from_git("javascript/integration", "appsignal-javascript")
    reset_repo("javascript/integration")
  end

  desc "Reset integrations"
  task :reset do
    # Ruby
    reset_repo("ruby/integration")
    # Elixir
    reset_repo("elixir/integration/appsignal-elixir-phoenix")
    reset_repo("elixir/integration/appsignal-phoenix")
    reset_repo("elixir/integration/appsignal-plug")
    # Node.js
    reset_repo("nodejs/integration", branch: "make")
    # JavaScript
    reset_repo("javascript/integration")
  end

  desc "Remove integrations"
  task :clean do
    run_command("rm -rf ruby/integration")
    run_command("rm -rf elixir/integration")
    run_command("rm -rf nodejs/integration")
    run_command("rm -rf javascript/integration")
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

  desc "Set the push api key to use"
  task :set_push_api_key do
    @key = ENV['key'] or raise "No key provided"
    puts "Setting push api key in appsignal_key.env"
    File.write "appsignal_key.env", render_erb("support/templates/appsignal_key.env.erb")
  end
end

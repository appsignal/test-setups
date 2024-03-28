plugin :appsignal

workers 2

threads 5, 5

port 4001

debug

app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/shared"

# Default to production
environment "production"

# Set up socket location
bind "unix:///#{shared_dir}/sockets/puma.sock"

# stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"
activate_control_app

# Another test scenario using prune_bundler, enable both lines:
# prune_bundler
# extra_runtime_dependencies ["appsignal"]

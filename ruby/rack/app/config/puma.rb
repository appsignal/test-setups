plugin :appsignal

# Only 1 worker and thread to break it more easily
workers 0
threads 1, 1

port 4001

debug

app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/shared"

# Default to production
environment "production"

# Set up socket location
bind "unix:///#{shared_dir}/sockets/puma.sock"

pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"
activate_control_app

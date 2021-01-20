# Flush directly to STDOUT so we can see it in the Docker output before the end
# of the program
$stdout.sync = true
$stderr.sync = true

# Setup AppSignal
require "appsignal"
require "appsignal/integrations/object"
Appsignal.config = Appsignal::Config.new(
  File.expand_path(File.dirname(__FILE__)),
  "production"
)
Appsignal.start_logger
Appsignal.start

at_exit do
  # Make sure all transactions are flushed to the Agent.
  Appsignal.stop
  sleep 5
end

# The app itself
class Monitor
  def perform(param1, options = {}, foo:, bar:)
    Appsignal.instrument("perform.do_stuff") do
      puts "Monitor is doing stuff. Params: #{param1}, #{options}, #{foo}, #{bar}"
      sleep 1
    end
  end
  appsignal_instrument_method :perform
end

20.times do |i|
  Appsignal.monitor_transaction("perform_job.monitor", :class => "Monitor", :method => "loop") do
    Monitor.new.perform("foo", { :foo => i }, foo: i, bar: i.even?)
  end
  sleep 1
end

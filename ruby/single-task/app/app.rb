# Flush directly to STDOUT so we can see it in the Docker output before the end
# of the program
$stdout.sync = true
$stderr.sync = true

require "securerandom"
# Setup AppSignal
require "appsignal"
require "appsignal/integrations/object"

Appsignal.start

at_exit do
  # Make sure all transactions are flushed to the Agent.
  Appsignal.stop
  sleep 5
end

class CustomError < StandardError; end

# The app itself
class Monitor
  def perform(param1, options = {}, foo:, error:)
    Appsignal.instrument("perform.do_stuff") do
      puts "Monitor is doing stuff. Params: #{param1}, #{options}, #{foo}, #{error}"
      sleep 1
    end
  end
  appsignal_instrument_method :perform
end

5.times do |i|
  # Test with monitor helper
  begin
    Appsignal.monitor(:action => :MonitorTransaction) do
      Appsignal::CheckIn.cron("testing") do
        Monitor.new.perform("foo", { :foo => i }, foo: i, error: i.even?)
      end
    end
    # Do nothing, tracked by monitor
  end
end

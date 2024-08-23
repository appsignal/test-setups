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
    Appsignal.increment_counter "test_counter", rand(1..3), "host" => "my-host"
    Appsignal.set_gauge "test_gauge", rand(1..100), "host" => "my-host"
    Appsignal.add_distribution_value "test_distribution", rand(1..100), "host" => "my-host"

    raise CustomError, "Demo error" if error
  end
  appsignal_instrument_method :perform
end

20.times do |i|
  # Test with monitor_transaction helper
  begin
    Appsignal.monitor_transaction("perform_job.monitor", :class => "MonitorTransaction", :method => "loop") do
      Monitor.new.perform("foo", { :foo => i }, foo: i, error: i.even?)
    end
  rescue CustomError
    # Do nothing, tracked by monitor_transaction
  end

  # Test using transaction class directly, like most AppSignal integrations do
  begin
    transaction = Appsignal::Transaction.create(
      SecureRandom.uuid,
      Appsignal::Transaction::HTTP_REQUEST,
      Appsignal::Transaction::GenericRequest.new({})
    )
    Monitor.new.perform("foo", { :foo => i }, foo: i, error: i.even?)
  rescue => error
    transaction.set_error(error)
  ensure
    transaction.set_action_if_nil("MonitorCustomTransaction#loop")
    Appsignal::Transaction.complete_current!
  end

  sleep 1
end

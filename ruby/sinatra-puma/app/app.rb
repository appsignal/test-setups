require "appsignal"
require "sinatra"

Appsignal.load(:sinatra)
Appsignal.start

get "/" do
  time = Time.now.strftime("%H:%M")
  <<~HTML
    <h1>Sinatra + Puma example app</h1>

    <p>Run the <code>console</code> command for this app to "phased restart" this app.</p>

    <ul>
      <li><a href="/slow?time=#{time}">Slow request</a></li>
      <li><a href="/error?time=#{time}">Error request</a></li>
      <li><a href="/stream/slow?time=#{time}">Slow streaming request</a></li>
      <li><a href="/stream/error?time=#{time}">Streaming request with error</a></li>
      <li><a href="/errors?time=#{time}">Multiple errors with custom instrumentation</a></li>
      <li><a href="/cron?time=#{time}">Custom cron check-in</a></li>
    </ul>
  HTML
end

get "/slow" do
  sleep 3
  "ZzZzZzZ.."
end

get "/error" do
  raise "error"
end

class SomeCustomError < StandardError
end

class AnotherCustomError < StandardError
end

get "/errors" do
  transaction = Appsignal::Transaction.current

  [SomeCustomError, AnotherCustomError, StandardError].each do |cls|
    begin
      raise cls.new("I am one of multiple errors")
    rescue => e
      transaction.add_error(e)
    end
  end

  Appsignal.set_custom_data({
    "time" => Time.now.to_s,
    "custom" => "data"
  })

  "Errors sent!"
end

get "/stream/slow" do
  stream do |out|
    sleep 1
    out << "1"
    sleep 1
    out << "2"
    sleep 1
    out << "3"
  end
end

get "/stream/error" do
  stream do |out|
    out << "a"
    sleep 0.5
    out << "b"
    raise "Sinatra error in streaming body"
  end
end

get "/cron" do
  Appsignal::CheckIn.cron("custom-cron-checkin") do
    sleep 3
  end

  "Cron check-in sent!"
end

require "sinatra"
require "appsignal"
require "appsignal/integrations/sinatra"

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

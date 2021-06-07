require "sinatra"
require "appsignal"
require "appsignal/integrations/sinatra"

# Re-register the puma probe with the puma server url and auth token
Appsignal::Minutely.probes.register(
  :puma,
  Appsignal::Probes::PumaProbe.new(:path => ENV["PUMA_URL"], :auth_token => ENV["PUMA_TOKEN"])
)

get "/" do
  time = Time.now.strftime("%H:%M")
  <<~HTML
    <h1>Sinatra + Puma example app</h1>

    <p>Run the <code>console</code> command for this app to "phased restart" this app.</p>

    <ul>
      <li><a href="/slow?time=#{time}">Slow request</a></li>
      <li><a href="/error?time=#{time}">Error request</a></li>
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

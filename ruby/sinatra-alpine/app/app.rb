require "active_support"
require "action_mailer"
require "sinatra"
require "appsignal"
require "appsignal"

Appsignal.load(:sinatra)
Appsignal.start

get "/" do
  time = Time.now.strftime("%H:%M")
  <<~HTML
    <h1>Sinatra example app</h1>

    <ul>
      <li><a href="/slow?time=#{time}">Slow request</a></li>
      <li><a href="/error?time=#{time}">Error request</a></li>
      <li><a href="/item/123?time=#{time}">Route with param request</a></li>
    </ul>
  HTML
end

get "/slow" do
  sleep 3
  "ZzZzZzZ.."
end

get "/error" do
  Appsignal.add_breadcrumb("test", "action")
  Appsignal.add_breadcrumb("category", "action", "message", { "metadata_key" => "some value" })
  raise "error"
end

get "/item/:id" do
  "Item with id #{params[:id]}"
end

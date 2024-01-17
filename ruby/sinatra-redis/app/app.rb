require "active_support"
require "action_mailer"
require "sinatra"
require "redis"
require "appsignal"
require "appsignal/integrations/sinatra"

get "/" do
  time = Time.now.strftime("%H:%M")
  <<~HTML
    <h1>Sinatra example app</h1>

    <ul>
      <li><a href="/slow?time=#{time}">Slow request</a></li>
      <li><a href="/error?time=#{time}">Error request</a></li>
      <li><a href="/redis?time=#{time}">Redis request</a></li>
      <li><a href="/item/123?time=#{time}">Route with param request</a></li>
    </ul>
  HTML
end

get "/slow" do
  sleep 3
  "ZzZzZzZ.."
end

def original_error
  raise "I am the original error!"
end

get "/error" do
  Appsignal.add_breadcrumb("test", "action")
  Appsignal.add_breadcrumb("category", "action", "message", { "metadata_key" => "some value" })
  original_error
rescue
  raise "I am a wrapper error!"
end

get "/redis" do
  redis = Redis.new(url: ENV.fetch("REDIS_URL"))
  greetings = ["hi", "hello", "howdy"]

  redis.set("greeting", greetings.sample)
  "Redis says #{redis.get("greeting")}!"
end

get "/item/:id" do
  "Item with id #{params[:id]}"
end

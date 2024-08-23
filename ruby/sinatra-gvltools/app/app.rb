require "active_support"
require "action_mailer"
require "sinatra"
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
      <li><a href="/threads">Spawn threads</a></li>
    </ul>
  HTML
end

def fibonacci(number)
  number <= 1 ? number : fibonacci(number - 1) + fibonacci(number - 2)
end

get "/threads" do
  5.times.map do
    Thread.new do
      5.times do
        fibonacci(30)
      end
    end
  end.each do |thread|
    thread.join
  end

  "Spawned and joined some threads!"
end

get "/slow" do
  sleep 3
  "ZzZzZzZ.."
end

get "/error" do
  raise "error"
end

require "rack"

class MyApp
  def call(env)
    case [env["REQUEST_METHOD"], env["PATH_INFO"]]
    when ["GET", "/"]
      Appsignal.set_action("GET /")
      body = <<~BODY
        <h1>Rack example app</h1>

        <ul>
          <li><a href="/slow">Slow request</a></li>
          <li><a href="/error">Error request</a></li>
        </ul>
      BODY
      [200, {"Content-Type" => "text/html"}, [body]]
    when ["GET", "/slow"]
      Appsignal.set_action("GET /slow")
      sleep 3
      [200, {"Content-Type" => "text/plain"}, ["Slow response"]]
    when ["GET", "/error"]
      Appsignal.set_action("GET /error")
      raise "uh oh"
    else
      Appsignal.set_action("NotFound")
      [404, {"Content-Type" => "text/plain"}, ["Page not found"]]
    end
  end
end

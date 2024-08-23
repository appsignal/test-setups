require "webmachine"
require "appsignal"

Appsignal.start

Webmachine.application.configure do |config|
  config.port = ENV["PORT"]
end

class MyPerformanceResource < Webmachine::Resource
  def to_html
    sleep 3

    <<~HTML
      <html>
        <body>
          ZzZzZz
        </body>
      </html>
    HTML
  end
end

class MyErrorResource < Webmachine::Resource
  def to_html
    raise "Fatal Webmachine app error!"
  end
end

class MyRootResource < Webmachine::Resource
  def to_html
    time = Time.now.utc
    params = "?time=#{time.hour}:#{time.min}:#{time.sec}"
    <<~HTML
      <html>
        <body>
          <h1>Hello webmachine app!</h1>
          <ul>
            <li><a href="/slow#{params}">Slow request</a></li>
            <li><a href="/error#{params}">Error request</a></li>
          </ul>
        </body>
      </html>
    HTML
  end
end

Webmachine.application.routes do
  add ["slow"], MyPerformanceResource
  add ["error"], MyErrorResource
  add [], MyRootResource
end

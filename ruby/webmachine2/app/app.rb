require "webmachine"
require "net/http"
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

# Makes an HTTP request to a second, separately-instrumented webmachine app (the
# `downstream` service). AppSignal's Net::HTTP integration injects the current
# W3C trace context onto the request in collector mode, and the downstream app's
# Webmachine integration extracts it -- so the trace spans both apps. This
# exercises Webmachine's trace-context extraction, the one server path that is
# not shared with the Rack integrations. Falls back to calling itself when
# DOWNSTREAM_URL is unset.
class CallDownstreamResource < Webmachine::Resource
  def to_html
    url = ENV.fetch("DOWNSTREAM_URL", "http://localhost:4001")
    Net::HTTP.get(URI("#{url}/"))
    "<html><body>Called downstream app</body></html>"
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
            <li><a href="/call_downstream#{params}">Call downstream app (cross-service trace)</a></li>
          </ul>
        </body>
      </html>
    HTML
  end
end

Webmachine.application.routes do
  add ["slow"], MyPerformanceResource
  add ["error"], MyErrorResource
  add ["call_downstream"], CallDownstreamResource
  add [], MyRootResource
end

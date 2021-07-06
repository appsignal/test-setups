require "sinatra"
require "appsignal"
require "appsignal/integrations/sinatra"

ARM_ARCH = "aarch64".freeze

get "/" do
  time = Time.now.strftime("%H:%M")
  detected_arch = RbConfig::CONFIG["host_cpu"]
  arm_message =
    if ARM_ARCH == detected_arch
      "✅ Image is an ARM image."
    else
      "❌ Image is <strong>not</strong> an ARM image."
    end
  <<~HTML
    <h1>Sinatra Linux ARM example app</h1>
    <p>#{arm_message}</p>
    <ul>
      <li>Detected architecture: #{detected_arch}</li>
      <li>Expected architecture: #{ARM_ARCH}</li>
    </ul>

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

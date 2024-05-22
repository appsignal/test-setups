require "appsignal"

Appsignal.start
Appsignal.start_logger

class App
  def call(env)
    req =
      Appsignal.instrument "parse.request" do
        Rack::Request.new(env)
      end
    handle_route(req.path_info)
  end

  def handle_route(path)
    Appsignal.instrument "handle.route" do
      Appsignal.set_action("GET #{path}")
      case path
      when "/"
        render_index
      when "/slow"
        render_slow
      when "/error"
        render_error
      when "/array"
        render_array
      else
        handle_missing_path(path)
      end
    end
  end

  def render_index
    view =
      Appsignal.instrument "render.view" do
        <<~VIEW
          <h1>Rack app</h1>
          <ul>
            <li><a href="/slow">Slow request</a></li>
            <li><a href="/error">Error request</a></li>
            <li><a href="/array">Array body response</a></li>
          </ul>
        VIEW
      end
    [200, {}, [view]]
  end

  def render_slow
    Appsignal.instrument "be.slow" do
      sleep 1
    end
    [200, {}, ["Slow request!"]]
  end

  def render_error
    raise "An error!"
  end

  def render_array
    body = MyResponseBody.new
    Appsignal.instrument "do.stuff" do
      body << "abc"
      Appsignal.instrument "do_more.stuff" do
        body << "def"
      end
    end
    [200, {}, body]
  end

  def handle_missing_path(path)
    [404, {}, ["Unknown path: #{path}"]]
  end
end

class MyResponseBody
  def initialize
    @body = []
  end

  def <<(value)
    @body << value
  end

  def to_ary
    puts "!!! to_ary"
    @body
  end
end

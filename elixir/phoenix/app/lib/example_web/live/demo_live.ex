defmodule ExampleWeb.DemoLive do
  use ExampleWeb, :live_view

  def mount(_params, session, socket) do
    # Set AppSignal sample data
    root_span = Appsignal.Tracer.root_span()

    Appsignal.Span.set_sample_data(root_span, "session_data", %{
      user_id: session["user_id"]
    })

    # Extract environment data
    environment_data = %{}

    # Get remote IP from peer_data
    peer_data = get_connect_info(socket, :peer_data)
    environment_data =
      case peer_data do
        %{address: address} when not is_nil(address) ->
          Map.put(environment_data, :remote_ip, address |> :inet.ntoa() |> to_string())
        _ ->
          environment_data
      end

    # Get user agent
    user_agent = get_connect_info(socket, :user_agent)
    environment_data =
      case user_agent do
        ua when not is_nil(ua) and ua != "" ->
          Map.put(environment_data, :user_agent, ua)
        _ ->
          environment_data
      end

    # Always set environment data (even if empty) for debugging
    # In production, you might want to only set if not empty
    Appsignal.Span.set_sample_data(root_span, "environment", environment_data)

    Appsignal.Span.set_sample_data(root_span, "custom_data", %{name: "John Doe"})

    {:ok, assign(socket, :brightness, 50)}
  end

  def handle_params(unsigned_params, uri, socket) do
    IO.puts("handle_params event")
    IO.inspect([unsigned_params, uri, socket])
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>LiveView test light</h1>

    <div class="light">
      <div class="bar" style={"width: #{@brightness}%"}>
        <%= @brightness %>%
      </div>
    </div>

    <button phx-click="down">
      Down
    </button>

    <button phx-click="up">
      Up
    </button>

    <hr />

    <.live_component module={ExampleWeb.LiveComponent} id="component" />
    """
  end

  def handle_event("down", _, socket) do
    IO.puts("LiveView handle_event down")
    brightness = socket.assigns.brightness - 10
    socket = assign(socket, :brightness, brightness)
    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    IO.puts("LiveView handle_event up")
    brightness = socket.assigns.brightness + 10
    socket = assign(socket, :brightness, brightness)
    {:noreply, socket}
  end
end

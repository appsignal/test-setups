defmodule AppWeb.TicketLive.Show do
  use AppWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Ticket {@ticket.id}
        <:subtitle>This is a ticket record from your database.</:subtitle>

        <:actions>
          <.button navigate={~p"/tickets"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/tickets/#{@ticket}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit Ticket
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Id">{@ticket.id}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Ticket")
     |> assign(:ticket, Ash.get!(Helpdesk.Support.Ticket, id, actor: socket.assigns.current_user))}
  end
end

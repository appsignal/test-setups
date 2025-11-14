defmodule AppWeb.TicketLive.Index do
  use AppWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Tickets
        <:actions>
          <.button variant="primary" navigate={~p"/tickets/new"}>
            <.icon name="hero-plus" /> New Ticket
          </.button>
        </:actions>
      </.header>

      <.table
        id="tickets"
        rows={@streams.tickets}
        row_click={fn {_id, ticket} -> JS.navigate(~p"/tickets/#{ticket}") end}
      >
        <:col :let={{_id, ticket}} label="Id">{ticket.id}</:col>

        <:action :let={{_id, ticket}}>
          <div class="sr-only">
            <.link navigate={~p"/tickets/#{ticket}"}>Show</.link>
          </div>

          <.link navigate={~p"/tickets/#{ticket}/edit"}>Edit</.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Tickets")
     |> assign_new(:current_user, fn -> nil end)
     |> stream(:tickets, Ash.read!(Helpdesk.Support.Ticket, actor: socket.assigns[:current_user]))}
  end
end

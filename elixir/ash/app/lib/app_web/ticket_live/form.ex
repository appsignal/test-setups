defmodule AppWeb.TicketLive.Form do
  use AppWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage ticket records in your database.</:subtitle>
      </.header>

      <.form
        for={@form}
        id="ticket-form"
        phx-change="validate"
        phx-submit="save"
      >
        <.button phx-disable-with="Saving..." variant="primary">Save Ticket</.button>
        <.button navigate={return_path(@return_to, @ticket)}>Cancel</.button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    ticket =
      case params["id"] do
        nil -> nil
        id -> Ash.get!(Helpdesk.Support.Ticket, id, actor: socket.assigns.current_user)
      end

    action = if is_nil(ticket), do: "New", else: "Edit"
    page_title = action <> " " <> "Ticket"

    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(ticket: ticket)
     |> assign(:page_title, page_title)
     |> assign_form()}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  @impl true
  def handle_event("validate", %{"ticket" => ticket_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, ticket_params))}
  end

  def handle_event("save", %{"ticket" => ticket_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: ticket_params) do
      {:ok, ticket} ->
        notify_parent({:saved, ticket})

        socket =
          socket
          |> put_flash(:info, "Ticket #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: return_path(socket.assigns.return_to, ticket))

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{ticket: ticket}} = socket) do
    form =
      if ticket do
        AshPhoenix.Form.for_update(ticket, :update,
          as: "ticket",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Helpdesk.Support.Ticket, :create,
          as: "ticket",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  defp return_path("index", _ticket), do: ~p"/tickets"
  defp return_path("show", ticket), do: ~p"/tickets/#{ticket.id}"
end

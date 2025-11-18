defmodule AshExampleWeb.TaskLive do
  use AshExampleWeb, :live_view
  alias AshExample.Tasks.Task

  # For testing tenant metadata - in production this could come from session/auth
  @test_tenant "tenant_123"

  def mount(_params, _session, socket) do
    tasks = Task.read!(tenant: @test_tenant)

    {:ok,
     socket
     |> assign(:tasks, tasks)
     |> assign(:form, to_form(%{"title" => "", "description" => ""}))}
  end

  def handle_event("create_task", %{"title" => title, "description" => description}, socket) do
    case Task.create(%{title: title, description: description}, tenant: @test_tenant) do
      {:ok, _task} ->
        tasks = Task.read!(tenant: @test_tenant)

        {:noreply,
         socket
         |> assign(:tasks, tasks)
         |> assign(:form, to_form(%{"title" => "", "description" => ""}))
         |> put_flash(:info, "Task created successfully!")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to create task")}
    end
  end

  def handle_event("complete_task", %{"id" => id}, socket) do
    task = Enum.find(socket.assigns.tasks, fn t -> t.id == id end)

    case Task.complete(task, tenant: @test_tenant) do
      {:ok, _task} ->
        tasks = Task.read!(tenant: @test_tenant)
        {:noreply, assign(socket, :tasks, tasks)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to complete task")}
    end
  end

  def handle_event("delete_task", %{"id" => id}, socket) do
    task = Enum.find(socket.assigns.tasks, fn t -> t.id == id end)

    case Task.destroy(task, tenant: @test_tenant) do
      :ok ->
        tasks = Task.read!(tenant: @test_tenant)
        {:noreply, assign(socket, :tasks, tasks)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to delete task")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-8">Task Manager</h1>

      <div class="mb-8 bg-white shadow-md rounded-lg p-6">
        <h2 class="text-xl font-semibold mb-4">Create New Task</h2>
        <.form for={@form} phx-submit="create_task" class="space-y-4">
          <div>
            <label class="block text-sm font-medium mb-2">Title</label>
            <input
              type="text"
              name="title"
              value={@form.data["title"]}
              required
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label class="block text-sm font-medium mb-2">Description</label>
            <textarea
              name="description"
              value={@form.data["description"]}
              rows="3"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
            </textarea>
          </div>
          <button
            type="submit"
            class="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 transition-colors"
          >
            Create Task
          </button>
        </.form>
      </div>

      <div class="space-y-4">
        <h2 class="text-xl font-semibold">Tasks</h2>
        <%= if Enum.empty?(@tasks) do %>
          <p class="text-gray-500">No tasks yet. Create one above!</p>
        <% else %>
          <%= for task <- @tasks do %>
            <div class="bg-white shadow-md rounded-lg p-4 flex items-start justify-between">
              <div class="flex-1">
                <h3 class={"text-lg font-medium #{if task.completed, do: "line-through text-gray-500", else: ""}"}>
                  <%= task.title %>
                </h3>
                <%= if task.description do %>
                  <p class={"text-gray-600 mt-1 #{if task.completed, do: "line-through", else: ""}"}>
                    <%= task.description %>
                  </p>
                <% end %>
                <p class="text-xs text-gray-400 mt-2">
                  <%= if task.completed do %>
                    <span class="text-green-600 font-medium">Completed</span>
                  <% else %>
                    <span class="text-yellow-600 font-medium">Pending</span>
                  <% end %>
                </p>
              </div>
              <div class="flex gap-2 ml-4">
                <%= if !task.completed do %>
                  <button
                    phx-click="complete_task"
                    phx-value-id={task.id}
                    class="px-3 py-1 bg-green-500 text-white rounded hover:bg-green-600 transition-colors text-sm"
                  >
                    Complete
                  </button>
                <% end %>
                <button
                  phx-click="delete_task"
                  phx-value-id={task.id}
                  class="px-3 py-1 bg-red-500 text-white rounded hover:bg-red-600 transition-colors text-sm"
                >
                  Delete
                </button>
              </div>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end
end

# AshExample

An example Phoenix LiveView application using the Ash Framework for resource management.

## Features

This application demonstrates:
- **Ash Framework** integration with Phoenix LiveView
- A Task resource with CRUD operations (Create, Read, Update, Delete)
- Real-time UI updates using Phoenix LiveView
- Task completion action to mark tasks as done

## Getting Started

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Available Routes

- `/` - Home page with link to Task Manager
- `/tasks` - Task Manager demo page

## Ash Resources

### Task Resource

Located in `lib/ash_example/tasks/task.ex`, the Task resource includes:

**Attributes:**
- `id` - UUID primary key
- `title` - Required string
- `description` - Optional string
- `completed` - Boolean (default: false)
- `inserted_at` - Timestamp
- `updated_at` - Timestamp

**Actions:**
- `create` - Create a new task
- `read` - List all tasks
- `update` - Update task details
- `complete` - Mark a task as completed
- `destroy` - Delete a task

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

defmodule AppsignalPhoenixExampleWeb.UserController do
  use AppsignalPhoenixExampleWeb, :controller

  alias AppsignalPhoenixExample.Accounts
  alias AppsignalPhoenixExample.Accounts.User
  use Appsignal.Instrumentation.Decorators

  def index(conn, _params) do
    users = Accounts.list_users()
    slow()

    try do
      raise "Exception with set_error!"
    catch
      kind, reason ->
        stack = __STACKTRACE__

        # the following attempt works however what should work
        Appsignal.Span.add_error(Appsignal.Tracer.root_span(), kind, reason, stack)
        Appsignal.Span.set_sample_data(Appsignal.Tracer.root_span(), "tags", %{locale: "en"})

        # however the following does not work (this is how we show in the docs)
        # Appsignal.add_error(kind, reason, stack)
    end

    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    slow()
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    slow()

    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  @decorate transaction(:user)
  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end

  # Decorate this function to add custom instrumentation
  @decorate transaction_event()
  defp slow do
    :timer.sleep(1000)
  end
end

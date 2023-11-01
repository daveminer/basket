defmodule BasketWeb.UnauthenticatedHandler do
  @moduledoc false

  use BasketWeb, :controller

  alias Pow.Phoenix.Routes

  def call(conn, :not_authenticated) do
    conn
    |> put_flash(:error, "You must be logged in to access this page.")
    |> redirect(to: Routes.session_path(conn, :new))
  end
end

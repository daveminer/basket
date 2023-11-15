defmodule BasketWeb.Components.NavRow do
  @moduledoc """
  The header for the home page.
  """
  alias BasketWeb.Components.DarkModeToggle

  use Surface.Component

  def render(assigns) do
    ~F"""
    <div class="flex flex-row gap-4 items-center justify-end">
      <DarkModeToggle.render />
      <.link href="/session" method="delete">Sign out</.link>
    </div>
    """
  end
end

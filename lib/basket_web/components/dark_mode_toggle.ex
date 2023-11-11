defmodule BasketWeb.Components.DarkModeToggle do
  @moduledoc """
  A sample component generated by `mix surface.init`.
  """
  use Surface.Component

  import BasketWeb.CoreComponents

  @doc """
  The max width.

  sm: `max-w-sm`, md: `max-w-md`, lg: `max-w-lg`
  """
  prop max_width, :string, values: ["sm", "md", "lg"]

  def render(assigns) do
    ~F"""
    <div class="justify-center">
      <input type="checkbox" name="light-switch" class="light-switch sr-only" />
      <label class="relative cursor-pointer p-2" for="light-switch">
        <.icon name="hero-sun-solid" class="dark:hidden w-8 h-8" />
        <.icon name="hero-moon-solid" class="hidden dark:block w-8 h-8" />
        <span class="sr-only">Switch between light and dark mode</span>
      </label>
    </div>
    """
  end
end

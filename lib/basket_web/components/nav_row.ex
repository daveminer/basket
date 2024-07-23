defmodule BasketWeb.Components.NavRow do
  @moduledoc """
  The header for the home page.
  """

  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <div class="navbar bg-base-200 rounded-xl mb-5">
      <div class="flex-1">
        <a class="btn btn-ghost text-xl" href="/">Basket</a>
      </div>
      <div class="flex-none dropdown dropdown-hover">
        <div role="button" class="btn btn-square btn-ghost" tabindex="0">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            class="inline-block h-5 w-5 stroke-current"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M5 12h.01M12 12h.01M19 12h.01M6 12a1 1 0 11-2 0 1 1 0 012 0zm7 0a1 1 0 11-2 0 1 1 0 012 0zm7 0a1 1 0 11-2 0 1 1 0 012 0z"
            >
            </path>
          </svg>
        </div>
        <ul tabindex="0" class="dropdown-content menu bg-base-100 rounded-box z-[1] w-52 p-2 shadow">
          <li>
            <.link href="/settings">Settings</.link>
          </li>
          <li>
            <.link href="/session" method="delete">Sign out</.link>
          </li>
        </ul>
      </div>
    </div>
    """
  end
end

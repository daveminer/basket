defmodule BasketWeb.SettingsHTML do
  use BasketWeb, :html

  alias BasketWeb.Components.NavRow

  def index(assigns) do
    ~H"""
    <div class="flex-col p-4">
      <NavRow.render id="nav-row" />

      <%= if @officer do %>
        <.form for={@form} class="flex flex-col" action="/invitations" method="post">
          <span class="mr-2">
            Send a club invite
          </span>
          <div class="w-50">
            <input name="user[email]" class="input input-bordered" placeholder="someone@xyz.com" />
            <button type="submit" class="btn">
              Invite
            </button>
          </div>
        </.form>
      <% end %>
    </div>
    """
  end
end

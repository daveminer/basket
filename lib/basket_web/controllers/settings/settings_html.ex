defmodule BasketWeb.SettingsHTML do
  use BasketWeb, :html

  alias BasketWeb.Components.NavRow

  def index(assigns) do
    ~H"""
    <div class="flex-col bg-base-100 p-8">
      <NavRow.render id="nav-row" />

      <div class="flex flex-col gap-4 mt-8">
        <div class="flex flex-col gap-2">
          <span class="text-3xl">Account</span>
          <span>Email: <%= @current_user.email %></span>
          <span>
            Name: <%= @current_user.first_name %> <%= @current_user.last_name %>
          </span>
          <%= if length(@current_user.clubs) > 0 do %>
            <span>
              Membership: <%= @current_user.clubs |> hd() |> Map.get(:name) %>
            </span>
          <% end %>
          <%= if length(@current_user.offices) > 0 do %>
            <span>
              Office: <%= @current_user.offices |> hd() |> Map.get(:name) %>
            </span>
          <% end %>
        </div>
      </div>

      <%= if @current_user.offices > 0 do %>
        <.form for={@form} class="flex flex-col mt-8" action="/invitations" method="post">
          <span class="mr-2 text-xl">
            Send a club invite
          </span>
          <div class="w-50">
            <input name="user[email]" class="input input-bordered" placeholder="someone@xyz.com" />
            <button type="submit" class="btn btn-primary ms-4">
              Invite
            </button>
          </div>
        </.form>
      <% end %>
    </div>
    """
  end
end

defmodule BasketWeb.Live.Overview.ClubToggle do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <div class="flex items-center">
      <span class="club-toggle-label">Club</span>
      <input
        type="checkbox"
        class="toggle mx-3"
        checked={@user.settings["ticker_view_toggle"] != "club"}
        phx-click="club-view-toggle"
        phx-value-toggle={@user.settings["ticker_view_toggle"] != "club"}
      />
      <span class="individual-toggle-label">Individual</span>
    </div>
    """
  end
end

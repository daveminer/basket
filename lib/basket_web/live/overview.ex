defmodule BasketWeb.Live.Overview do
  @moduledoc """
  Home page shows a list of assets and updates them in realtime via websockets.
  """
  use Phoenix.LiveView

  require Logger

  alias Basket.{ClubTicker, Repo, Ticker, User}
  alias BasketWeb.Components.NavRow
  alias BasketWeb.Live.Overview.{Search, TickerBarTable}
  alias BasketWeb.Presence

  on_mount {BasketWeb.Live.UserLiveAuth, :user}

  def mount(_, _, socket) do
    {:ok, initialize(socket)}
  end

  def handle_info({"ticker-add", %{"ticker" => ticker}}, socket) do
    if ticker in tickers(socket) or String.trim(ticker) == "" do
      {:noreply, socket}
    else
      user = socket.assigns.user

      case user.settings["ticker_view_toggle"] do
        "club" ->
          user.clubs |> dbg()
          ClubTicker.add!(user.clubs |> List.first(), ticker)

        "individual" ->
          Ticker.add!(user, ticker)
      end

      {:noreply, add_tickers_to_view(socket, ["#{ticker}"])}
    end
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{topic: _topic, event: "ticker-update", payload: payload},
        socket
      ) do
    updated_socket = push_event(socket, "ticker-update-received", payload)

    {:noreply, updated_socket}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{topic: _, event: "presence_diff", payload: _},
        socket
      ) do
    {:noreply, socket}
  end

  def handle_event("ticker-remove", %{"ticker" => ticker}, socket) do
    user = socket.assigns.user

    case user.settings["ticker_view_toggle"] do
      "club" ->
        ClubTicker.remove(user.clubs |> List.first(), ticker)

      "individual" ->
        Ticker.remove(user, ticker)
    end

    Presence.untrack(self(), "bars-#{ticker}", user.id)

    socket =
      assign(
        socket,
        :basket,
        Enum.reject(socket.assigns.basket, fn row -> row.ticker == ticker end)
      )

    {:noreply, socket}
  end

  def handle_event("club-view-toggle", params, socket) do
    new_setting =
      case params["value"] do
        "on" -> "individual"
        nil -> "club"
      end

    Enum.each(tickers(socket), fn ticker ->
      Presence.untrack(self(), "bars-#{ticker}", socket.assigns.user.id)
    end)

    user = User.toggle_club_view!(socket.assigns.user, new_setting)

    socket = assign(socket, basket: [], user: user)

    socket =
      case load_tickers(user) do
        [] -> socket
        tickers -> add_tickers_to_view(socket, tickers)
      end

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex-col p-8">
      <NavRow.render id="nav-row" />
      <div class="flex justify-between items-center">
        <.live_component module={Search} id="stock-search-input" />
        <div :if={length(@user.clubs) > 0} class="flex items-center">
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
      </div>
      <TickerBarTable.render id="ticker-bar-table" rows={@basket} />
    </div>
    """
  end

  defp add_tickers_to_view(socket, tickers) do
    case TickerBarTable.add_ticker(tickers, socket.assigns.user.id) do
      {:error, error} ->
        Logger.error("Could not add ticker: #{error}")
        socket

      {:ok, %{bars: bars}} ->
        new_rows = Enum.sort(socket.assigns.basket ++ bars, fn a, b -> a.ticker < b.ticker end)
        assign(socket, :basket, new_rows)
    end
  end

  defp load_tickers(user) do
    tickers =
      if user.settings["ticker_view_toggle"] == "club" do
        user = Repo.preload(user, :clubs)
        ClubTicker.for_club(user.clubs |> List.first())
      else
        Ticker.for_user(user)
      end

    case tickers do
      [] -> []
      assets -> Enum.map(assets, & &1.ticker)
    end
  end

  defp initialize(socket) do
    user = Repo.get(User, socket.assigns.user.id) |> Repo.preload(:clubs)

    user |> dbg()

    socket =
      assign(socket,
        basket: [],
        user: user
      )

    case load_tickers(user) do
      [] -> socket
      tickers -> add_tickers_to_view(socket, tickers)
    end
  end

  defp tickers(socket), do: Enum.map(socket.assigns.basket, fn row -> row.ticker end)
end

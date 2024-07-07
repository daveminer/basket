defmodule BasketWeb.Live.Overview do
  @moduledoc """
  Home page shows a list of assets and updates them in realtime via websockets.
  """
  use Phoenix.LiveView

  require Logger

  alias Basket.{ClubTicker, Repo, Ticker, User}
  alias BasketWeb.Components.NavRow
  alias BasketWeb.Live.Overview.{Search, TickerAdd, TickerBarTable}
  alias BasketWeb.Presence

  on_mount {BasketWeb.Live.UserLiveAuth, :user}

  def mount(_, _, socket) do
    user = Repo.get(User, socket.assigns.user.id) |> Repo.preload(:clubs)

    socket =
      assign(socket,
        basket: [],
        ticker_view_toggle: user.settings["ticker_view_toggle"],
        user: user
      )

    socket =
      case connected?(socket) do
        true ->
          initialize(socket)

        false ->
          socket
          # # TODO: put add_ticker in load_tickers?
          # case load_tickers(user) do
          #   [] -> socket
          #   tickers -> add_ticker(socket, tickers)
          # end
      else
        socket
      end

    {:ok, socket}
  end

  def handle_info({"ticker-add", %{"ticker" => ticker}}, socket) do
    if ticker in tickers(socket) or String.trim(ticker) == "" do
      {:noreply, socket}
    else
      Ticker.add!(socket.assigns.user, ticker)

      {:noreply, add_ticker(socket, ticker)}
    end
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{topic: _topic, event: "ticker-update", payload: payload},
        socket
      ) do
    updated_socket = push_event(socket, "ticker-update-received", payload)

    {:noreply, updated_socket}
  end

  @doc """
  Prevents the presence updates from being broadcast to the client.
  """
  def handle_info(
        %Phoenix.Socket.Broadcast{topic: _, event: "presence_diff", payload: _},
        socket
      ) do
    {:noreply, socket}
  end

  def handle_event("ticker-remove", %{"ticker" => ticker}, socket) do
    Ticker.remove(socket.assigns.user, ticker)
    Presence.untrack(self(), "bars-#{ticker}", socket.assigns.user.id)

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

    user = User.toggle_club_view!(socket.assigns.user, new_setting)

    socket =
      case load_tickers(user) do
        [] -> socket
        tickers -> add_ticker(socket, tickers)
      end

    {:noreply, assign(socket, user: user)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex-col p-8">
      <NavRow.render id="nav-row" />
      <div class="flex justify-between items-center">
        <.live_component module={Search} id="stock-search-input" />
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
      </div>
      <TickerBarTable.render id="ticker-bar-table" rows={@basket} />
    </div>
    """
  end

  defp add_ticker(socket, tickers) do
    case TickerAdd.call(tickers, socket.assigns.user.id) do
      {:error, error} ->
        Logger.error("Could not add ticker: #{error}")
        socket

      {:ok, %{bars: bars}} ->
        handle_ticker_add_result(bars, socket)
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

    tickers |> dbg()

    case tickers do
      [] -> []
      assets -> Enum.map(assets, & &1.ticker)
    end
  end

  defp handle_ticker_add_result(
         bar_rows,
         socket
       ) do
    new_rows = Enum.sort(socket.assigns.basket ++ bar_rows, fn a, b -> a.ticker < b.ticker end)
    assign(socket, :basket, new_rows)
  end

  defp initialize(socket) do
    user = Repo.get(User, socket.assigns.user.id) |> Repo.preload(:clubs)

    socket =
      assign(socket,
        basket: [],
        ticker_view_toggle: user.settings["ticker_view_toggle"],
        user: user
      )
  end

  defp tickers(socket), do: Enum.map(socket.assigns.basket, fn row -> row.ticker end)
end

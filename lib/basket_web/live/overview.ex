defmodule BasketWeb.Live.Overview do
  @moduledoc """
  Home page shows a list of assets and updates them in realtime via websockets.
  """
  use Phoenix.LiveView

  require Logger

  alias Basket.{ClubTicker, News, Repo, Ticker, User}
  alias BasketWeb.Components.NavRow
  alias BasketWeb.Live.Overview.{ClubToggle, Search, TickerBarTable}
  alias BasketWeb.Presence

  on_mount {BasketWeb.Live.UserLiveAuth, :user}

  def mount(_, _, socket) do
    socket = assign(socket, :basket, [])

    if connected?(socket) do
      {:ok, initialize(socket)}
    else
      {:ok, socket}
    end
  end

  def handle_info({"ticker-add", %{"ticker" => ticker}}, socket) do
    if ticker in tickers(socket) or String.trim(ticker) == "" do
      {:noreply, socket}
    else
      user = socket.assigns.user

      case club_mode?(user) do
        true ->
          ClubTicker.add!(user.clubs |> List.first(), ticker)

        false ->
          Ticker.add!(user, ticker)
      end

      {:noreply, add_tickers_to_view(socket, ticker)}
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

    case club_mode?(user) do
      true ->
        ClubTicker.remove(user.clubs |> List.first(), ticker)

      false ->
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

    socket = assign(socket, basket: [], news: [], user: user)

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
      <div class="flex justify-between items-center mb-5">
        <.live_component
          :if={!club_mode?(@user) || officer?(@user)}
          module={Search}
          id="stock-search-input"
        />
        <ClubToggle.render :if={in_club?(@user)} id="club-toggle" user={@user} />
      </div>
      <TickerBarTable.render
        id="ticker-bar-table"
        news={@news}
        rows={@basket}
        can_delete={!club_mode?(@user) || officer?(@user)}
      />
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

  defp club_mode?(user) do
    user.settings["ticker_view_toggle"] == "club"
  end

  defp in_club?(user) do
    case user.clubs do
      %Ecto.Association.NotLoaded{} -> false
      clubs -> Enum.any?(clubs)
    end
  end

  defp initialize(socket) do
    user = Repo.get(User, socket.assigns.user.id) |> Repo.preload([:clubs, :offices])

    socket =
      assign(socket,
        basket: [],
        user: user
      )

    case load_tickers(user) do
      [] ->
        socket

      tickers ->
        populate_socket(socket, tickers)
    end
  end

  defp load_tickers(user) do
    tickers =
      if club_mode?(user) do
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

  defp officer?(user), do: Enum.any?(user.offices)

  defp populate_socket(socket, tickers) do
    socket =
      if News.sentiment_enabled?() do
        assign(socket, news: News.sentiment_for_tickers(tickers))
      else
        socket
      end

    add_tickers_to_view(socket, tickers)
  end

  defp tickers(socket), do: Enum.map(socket.assigns.basket, fn row -> row.ticker end)
end

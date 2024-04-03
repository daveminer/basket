defmodule BasketWeb.Live.Overview do
  @moduledoc """
  Home page shows a list of assets and updates them in realtime via websockets.
  """
  use Surface.LiveView

  require Logger

  alias Basket.Ticker
  alias BasketWeb.Components.NavRow
  alias BasketWeb.Live.Overview.{Search, TickerAdd, TickerBarTable}
  alias BasketWeb.Presence

  on_mount {BasketWeb.Live.UserLiveAuth, :user}

  def mount(_, _, socket) do
    socket = assign(socket, :basket, [])

    socket =
      if connected?(socket) do
        tickers = load_user_tickers(socket.assigns.user)

        if tickers != [] do
          add_ticker(socket, tickers)
        else
          socket
        end
      else
        socket
      end

    {:ok, socket}
  end

  def handle_info({"ticker-add", %{"ticker" => ticker}}, socket) do
    if ticker in tickers(socket) or String.trim(ticker) == "" do
      {:noreply, socket}
    else
      Ticker.add(socket.assigns.user, ticker)

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

  def render(assigns) do
    ~F"""
    <div class="flex-col p-8">
      <NavRow />
      <div class="w-1/4">
        <.live_component module={Search} id="stock-search-input" />
      </div>
      <TickerBarTable id="ticker-bar-table" rows={@basket} />
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

  defp load_user_tickers(user) do
    case Ticker.for_user(user) do
      [] ->
        []

      assets ->
        Enum.map(assets, & &1.ticker)
    end
  end

  defp handle_ticker_add_result(
         bar_rows,
         socket
       ) do
    new_rows = Enum.sort(socket.assigns.basket ++ bar_rows, fn a, b -> a.ticker < b.ticker end)
    assign(socket, :basket, new_rows)
  end

  defp tickers(socket), do: Enum.map(socket.assigns.basket, fn row -> row.ticker end)
end

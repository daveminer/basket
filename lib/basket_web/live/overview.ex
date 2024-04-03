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

  @initial_temp_assigns [basket: []]

  def mount(_, _, socket) do
    socket = assign(socket, :basket, [])

    socket =
      if connected?(socket) do
        tickers = load_user_tickers(socket.assigns.user)

        if tickers != [] do
          result = TickerAdd.call(tickers, socket.assigns.user.id)
          handle_ticker_add_result(result, socket)
        else
          socket
        end
      else
        socket
      end

    {:ok, socket, temporary_assigns: @initial_temp_assigns}
  end

  def handle_info({"ticker-add", %{"ticker" => ticker}}, socket) do
    if ticker in tickers(socket) or String.trim(ticker) == "" do
      {:noreply, socket}
    else
      Ticker.add(socket.assigns.user, ticker)

      case TickerAdd.call(ticker, socket.assigns.user.id) do
        {:error, error} ->
          Logger.error("Could not add ticker: #{error}")
          {:noreply, socket}

        {:ok, %{bars: [bars]}} ->
          {:noreply, push_event(socket, "ticker-added", %{bars: bars})}
          # IO.inspect(result, label: "RESULT")
          # new_socket = handle_ticker_add_result(result, socket)
          # {:noreply, new_socket}
      end

      # IO.inspect(result, label: "RESULT")
      # new_socket = handle_ticker_add_result(result, socket)
      # new_socket = push_event(socket, "ticker-added", %{ticker: ticker})
      # {:noreply, new_socket}
    end
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{topic: _topic, event: "ticker-update", payload: payload},
        socket
      ) do
    # updated_socket = update(socket, :basket, fn _basket -> [TickerRow.new(payload)] end)
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

    socket = push_event(socket, "ticker-removed", %{ticker: ticker})

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

  defp load_user_tickers(user) do
    case Ticker.for_user(user) do
      [] ->
        []

      assets ->
        Enum.map(assets, & &1.ticker)
    end
  end

  defp handle_ticker_add_result(
         {:ok, %{bars: bar_rows, tickers_not_found: _tickers_not_found}},
         socket
       ) do
    # IO.inspect(bar_rows, label: "BAR_ROWS")

    update(socket, :basket, fn basket ->
      # IO.inspect(basket, label: "BASKET")
      bar_rows
    end)
  end

  defp tickers(socket), do: Enum.map(socket.assigns.basket, fn row -> row.ticker end)
end

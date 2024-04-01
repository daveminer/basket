defmodule BasketWeb.Live.Overview do
  @moduledoc """
  Home page shows a list of assets and updates them in realtime via websockets.
  """
  use Surface.LiveView

  require Logger

  alias Basket.Ticker
  alias BasketWeb.Components.NavRow
  alias BasketWeb.Live.Overview.{Search, TickerAdd, TickerBarTable, TickerRow}
  alias BasketWeb.Presence

  on_mount {BasketWeb.Live.UserLiveAuth, :user}

  @initial_temp_assigns [basket: []]

  def mount(_, _, socket) do
    socket = assign(socket, :basket, [])

    if connected?(socket) do
      tickers = load_user_tickers(socket.assigns.user)

      if tickers != [] do
        result = TickerAdd.call(tickers, socket.assigns.user.id)
        new_socket = handle_ticker_add_result(result, socket)
        {:ok, new_socket, temporary_assigns: @initial_temp_assigns}
      else
        {:ok, socket, temporary_assigns: @initial_temp_assigns}
      end
    else
      {:ok, socket, temporary_assigns: @initial_temp_assigns}
    end
  end

  def handle_info({"ticker-add", %{"ticker" => ticker}}, socket) do
    if ticker in tickers(socket) or String.trim(ticker) == "" do
      {:noreply, socket}
    else
      Ticker.add(socket.assigns.user, ticker)
      result = TickerAdd.call(ticker, socket.assigns.user.id)
      new_socket = handle_ticker_add_result(result, socket, add_method: :append)
      {:noreply, new_socket}
    end
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{topic: _topic, event: "ticker-update", payload: payload},
        socket
      ) do
    updated_socket = update(socket, :basket, fn _basket -> [TickerRow.new(payload)] end)

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

  # Define the default value for opts here, in the header.
  defp handle_ticker_add_result(result, socket, opts \\ [])

  defp handle_ticker_add_result(
         {:ok, %{bars: bar_rows, tickers_not_found: tickers_not_found}},
         socket,
         opts
       ) do
    socket =
      if tickers_not_found != [] do
        put_flash(
          socket,
          :info,
          "No data for tickers: #{Enum.join(tickers_not_found, ", ")}"
        )
      else
        socket
      end

    update(socket, :basket, fn _basket -> bar_rows end)
  end

  defp handle_ticker_add_result({:error, error}, socket, _opts) do
    Logger.error("Could not subscribe to ticker: #{error}")
    socket
  end

  defp tickers(socket), do: Enum.map(socket.assigns.basket, fn row -> row.ticker end)
end

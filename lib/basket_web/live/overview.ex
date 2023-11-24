defmodule BasketWeb.OverviewLive do
  @moduledoc """
  Home page shows a list of assets and updates them in realtime via websockets.
  """
  use Surface.LiveView

  require Logger

  alias Basket.Websocket
  alias BasketWeb.Components.NavRow
  alias BasketWeb.Live.Overview.{Search, TickerAdd, TickerBar}

  def mount(_, _, socket) do
    BasketWeb.Endpoint.subscribe(Websocket.Alpaca.bars_topic())

    socket = assign(socket, basket: [])

    {:ok, socket}
  end

  def handle_info({"ticker-add", %{"ticker" => ticker}}, socket) do
    if ticker in tickers(socket) or String.trim(ticker) == "" do
      {:noreply, socket}
    else
      socket =
        case TickerAdd.call(ticker) do
          row when is_map(row) ->
            :ok = Websocket.Alpaca.subscribe(%{bars: [ticker], quotes: [], trades: []})
            assign(socket, :basket, (socket.assigns.basket ++ [row]) |> sort_by_ticker())

          :market_closed ->
            # credo:disable-for-next-line
            # TODO: add market closed row
            socket

          :no_data ->
            put_flash(socket, :info, "No data for ticker: #{ticker}")

          {:error, error} ->
            Logger.error("Could not subscribe to ticker: #{error}")
            put_flash(socket, :error, "Something when wrong.")
        end

      {:noreply, socket}
    end
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{topic: "bars", event: "ticker-update", payload: bars},
        socket
      ) do
    ticker = bars["S"]

    new_basket =
      Enum.map(socket.assigns.basket, fn row ->
        if row["S"].value == ticker,
          do: new_ticker_row(row, bars),
          else: row
      end)

    {:noreply,
     assign(
       socket,
       :basket,
       new_basket
     )}
  end

  def handle_event("ticker-remove", %{"ticker" => ticker}, socket) do
    basket_tickers = tickers(socket)

    if ticker not in basket_tickers or String.trim(ticker) == "" do
      {:noreply, socket}
    else
      :ok = Websocket.Alpaca.unsubscribe(%{bars: [ticker], quotes: [], trades: []})

      {:reply, %{},
       assign(
         socket,
         :basket,
         Enum.filter(socket.assigns.basket, fn t -> t["S"].value != ticker end)
       )}
    end
  end

  def render(assigns) do
    ~F"""
    <div class="flex-col p-8">
      <NavRow />
      <div class="w-1/4">
        <.live_component module={Search} id="stock-search-input" />
      </div>
      <BasketWeb.Components.TickerBarTable id="ticker-bar-table" rows={@basket} />
    </div>
    """
  end

  defp new_ticker_row(row, bars) do
    Enum.reduce(row, %{}, fn {k, v}, acc ->
      new_value = Map.get(bars, k)
      Map.put(acc, k, %TickerBar{value: new_value, prev_value: v.value})
    end)
  end

  defp sort_by_ticker(bars),
    do:
      Enum.sort(bars, fn a, b ->
        a["S"].value < b["S"].value
      end)

  defp tickers(socket), do: Enum.map(socket.assigns.basket, &Map.get(&1, "S").value)
end

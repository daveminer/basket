defmodule BasketWeb.OverviewLive do
  @moduledoc """
  Home page shows a list of assets and updates them in realtime via websockets.
  """
  use Surface.LiveView

  require Logger

  alias Basket.{Http, Websocket}
  alias BasketWeb.Components.{NavRow, TickerBarTable}
  alias BasketWeb.Live.Overview.Search
  alias BasketWeb.Live.Overview.TickerBar

  def mount(_, _, socket) do
    BasketWeb.Endpoint.subscribe(Websocket.Alpaca.bars_topic())

    socket = assign(socket, basket: [])

    {:ok, socket}
  end

  def handle_info({"ticker-add", %{"search_value" => ticker}}, socket) do
    # def handle_info({"ticker-add", %{"selected_ticker" => ticker}}, socket) do
    IO.inspect("SOCKET: #{inspect(socket.assigns)}")
    basket_tickers = tickers(socket)

    if ticker in basket_tickers or String.trim(ticker) == "" do
      {:noreply, socket}
    else
      :ok = Websocket.Alpaca.subscribe(%{bars: [ticker], quotes: [], trades: []})

      socket =
        case Http.Alpaca.latest_quote(ticker) do
          {:ok, response} ->
            %{"bars" => ticker_bars} = response
            new_ticker_bars = Map.to_list(ticker_bars) |> List.first()
            # TODO: nil not a tuple - AKUMQ
            initial_bars = build_ticker_bars(elem(new_ticker_bars, 1))

            assign(
              socket,
              :basket,
              socket.assigns.basket ++
                [Map.merge(initial_bars, %{"S" => %TickerBar{value: ticker}})]
            )

          {:error, error} ->
            Logger.error("Could not subscribe to ticker: #{error}")
            # socket
        end

      {:noreply, socket}
    end
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{topic: "bars", event: "ticker-update", payload: bars},
        socket
      ) do
    IO.inspect("BASKET: #{inspect(socket.assigns.basket)}")
    IO.inspect("BARS: #{inspect(bars)}")
    ticker = bars["S"]

    new_basket =
      Enum.map(socket.assigns.basket, fn row ->
        if row["S"].value == ticker,
          do: new_ticker_row(row, bars),
          else: row
      end)

    IO.inspect("NB: #{inspect(new_basket)}")

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

  # def handle_event("ticker-search", %{"search_value" => _query}, socket) do
  #   if length(socket.assigns.tickers) > 0 do
  #     {:noreply, socket}
  #   else
  #     {_status, tickers} = Cachex.fetch(:assets, "all", fn _key -> load_tickers() end)

  #     {:reply, %{}, assign(socket, :tickers, tickers)}
  #   end
  # end

  def render(assigns) do
    ~F"""
    <div class="flex-col p-8">
      <NavRow />
      <div class="w-1/4">
        <.live_component module={Search} id="stock-search-input" />
      </div>
      <.live_component module={TickerBarTable} id="ticker-bar-table" rows={@basket} />
    </div>
    """
  end

  defp build_ticker_bars(ticker_bars) do
    if ticker_bars == %{} do
      %{"t" => "Market Closed"}
    else
      Enum.reduce(ticker_bars, %{}, fn {k, v}, acc ->
        Map.put(acc, k, %TickerBar{value: v})
      end)
    end
  end

  defp new_ticker_row(row, bars) do
    Enum.reduce(row, %{}, fn {k, v}, acc ->
      new_value = Map.get(bars, k)
      Map.put(acc, k, %TickerBar{value: new_value, prev_value: v.value})
    end)
  end

  defp tickers(socket), do: Enum.map(socket.assigns.basket, &Map.get(&1, "S").value)
end

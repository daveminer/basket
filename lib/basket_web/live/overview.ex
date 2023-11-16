defmodule BasketWeb.Overview do
  @moduledoc """
  Home page shows a list of assets and updates them in realtime via websockets.
  """
  use Surface.LiveView

  require Logger

  alias Basket.{Http, Websocket}
  alias BasketWeb.Components.{NavRow, SearchInput, TickerBarTable}

  prop tickers, :list, default: []

  def mount(_, _, socket) do
    BasketWeb.Endpoint.subscribe(Websocket.Alpaca.bars_topic())

    socket = assign(socket, tickers: [])
    socket = assign(socket, basket: [])

    {:ok, socket}
  end

  def handle_event("ticker-search", %{"selected-ticker" => _query}, socket) do
    if length(socket.assigns.tickers) > 0 do
      {:noreply, socket}
    else
      {_status, tickers} = Cachex.fetch(:assets, "all", fn _key -> load_tickers() end)

      {:reply, %{}, assign(socket, :tickers, tickers)}
    end
  end

  def handle_event("ticker-add", %{"selected-ticker" => ticker}, socket) do
    basket_tickers = tickers(socket)

    if ticker in basket_tickers or String.trim(ticker) == "" do
      {:noreply, socket}
    else
      :ok = Websocket.Alpaca.subscribe(%{bars: [ticker], quotes: [], trades: []})

      socket =
        case Http.Alpaca.latest_quote(ticker) do
          {:ok, response} ->
            %{"bars" => %{^ticker => bars}} = response

            initial_bars = for {k, v} <- bars, into: %{}, do: {k, {v, ""}}

            assign(
              socket,
              :basket,
              socket.assigns.basket ++ [Map.merge(initial_bars, %{"S" => {ticker, ""}})]
            )

          {:error, error} ->
            Logger.error("Could not subscribe to ticker: #{error}")
            socket
        end

      {:reply, %{}, socket}
    end
  end

  def handle_event("ticker-remove", %{"selected-ticker" => ticker}, socket) do
    basket_tickers = tickers(socket)

    if ticker not in basket_tickers or String.trim(ticker) == "" do
      {:noreply, socket}
    else
      :ok = Websocket.Alpaca.unsubscribe(%{bars: [ticker], quotes: [], trades: []})

      {:reply, %{},
       assign(
         socket,
         :basket,
         Enum.filter(socket.assigns.basket, fn t -> elem(t["S"], 0) != ticker end)
       )}
    end
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{topic: "bars", event: "ticker-update", payload: bars},
        socket
      ) do
    # Get the old ticker data
    old_ticker = Enum.find(socket.assigns.basket, fn t -> elem(t["S"], 0) == bars["S"] end)

    bars_with_changes =
      for {k, v} <- bars, into: %{} do
        if k in ["S", "T", "t", "n"] do
          {k, {v, ""}}
        else
          {k, {v, diff_direction(old_ticker[k], bars[k])}}
        end
      end

    new_basket =
      Enum.map(socket.assigns.basket, fn row ->
        if elem(row["S"], 0) == bars["S"],
          do: Map.merge(bars_with_changes, %{"S" => {bars["S"], ""}}),
          else: row
      end)

    {:noreply,
     assign(
       socket,
       :basket,
       new_basket
     )}
  end

  def render(assigns) do
    ~F"""
    <div class="flex-col p-8">
      <NavRow />
      <div class="w-1/4">
        <.live_component module={SearchInput} id="stock-search-input" tickers={@tickers} />
      </div>
      <TickerBarTable id="ticker-bar-table" rows={@basket} />
    </div>
    """
  end

  defp diff_direction(old, new) do
    cond do
      !is_tuple(old) -> "same"
      elem(old, 0) > new -> "up"
      elem(old, 0) < new -> "down"
      true -> "same"
    end
  end

  defp load_tickers do
    case Http.Alpaca.list_assets() do
      {:ok, result} ->
        tickers =
          Enum.map(result, fn asset ->
            asset["symbol"]
          end)

        {:commit, tickers}

      {:error, error} ->
        Logger.error("Could not fetch tickers: #{error}")

        {:ignore, []}
    end
  end

  defp tickers(socket) do
    Enum.map(socket.assigns.basket, &Map.get(&1, "S"))
    |> Enum.map(fn x -> if is_tuple(x), do: elem(x, 0), else: x end)
  end
end

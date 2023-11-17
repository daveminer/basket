defmodule BasketWeb.Overview do
  @moduledoc """
  Home page shows a list of assets and updates them in realtime via websockets.
  """
  use Surface.LiveView

  import BasketWeb.CoreComponents

  require Logger

  alias Basket.Alpaca.HttpClient
  alias Basket.Websocket.Alpaca
  alias BasketWeb.Components.{NavRow, SearchInput}
  alias BasketWeb.Overview.TickerBar

  prop tickers, :list, default: []

  def mount(_, _, socket) do
    BasketWeb.Endpoint.subscribe(Alpaca.bars_topic())

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
    :ok = Alpaca.subscribe(%{bars: [ticker], quotes: [], trades: []})

    socket =
      case HttpClient.latest_quote(ticker) do
        {:ok, response} ->
          %{"bars" => %{^ticker => bars}} = response

          initial_bars =
            Enum.reduce(
              bars,
              %{},
              fn {k, v}, acc -> Map.put(acc, k, %TickerBar{value: v}) end
            )
            |> Map.merge(%{"S" => %TickerBar{value: ticker}})

          assign(
            socket,
            :basket,
            socket.assigns.basket ++ [initial_bars]
          )

        {:error, error} ->
          Logger.error("Could not subscribe to ticker: #{error}")
          socket
      end

    {:reply, %{}, socket}
  end

  def handle_event("ticker-remove", %{"ticker" => ticker}, socket) do
    :ok = Alpaca.unsubscribe(%{bars: [ticker], quotes: [], trades: []})

    ticker_removed = Enum.filter(socket.assigns.basket, fn t -> t["S"].value != ticker end)

    {:reply, %{},
     assign(
       socket,
       :basket,
       ticker_removed
     )}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{topic: "bars", event: "ticker-update", payload: bars},
        socket
      ) do
    # Get the old ticker data
    old_ticker = Enum.find(socket.assigns.basket, fn t -> t["S"].value == bars["S"] end)

    bars_with_changes =
      Enum.reduce(bars, %{}, fn {k, v}, acc ->
        if k in ["S", "T", "t", "n"] do
          Map.put(acc, k, %TickerBar{value: v, prev_value: old_ticker[k].value})
        else
          Map.put(acc, k, {v, diff_direction(old_ticker[k], bars[k])})
        end
      end
      # for {k, v} <- bars, into: %{} do
      #   if k in ["S", "T", "t", "n"] do
      #     {k, {v, ""}}
      #   else
      #     {k, {v, diff_direction(old_ticker[k], bars[k])}}
      #   end
      # end

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
      <.table id="ticker-list" rows={@basket}>
        <:col :let={ticker} key="S" label="ticker">{elem(ticker["S"], 0)}</:col>
        <:col :let={ticker} key="o" label="open">{elem(ticker["o"], 0)}</:col>
        <:col :let={ticker} key="h" label="high">{elem(ticker["h"], 0)}</:col>
        <:col :let={ticker} key="l" label="low">{elem(ticker["l"], 0)}</:col>
        <:col :let={ticker} key="c" label="close">{elem(ticker["c"], 0)}</:col>
        <:col :let={ticker} key="v" label="volume">{elem(ticker["v"], 0)}</:col>
        <:col :let={ticker} key="t" label="timestamp">{elem(ticker["t"], 0)}</:col>
        <:col :let={ticker} label="remove">
          <.button phx-click="ticker-remove" phx-value-ticker={elem(ticker["S"], 0)}>
            Remove
          </.button>
        </:col>"
      </.table>
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
    case HttpClient.list_assets() do
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
end

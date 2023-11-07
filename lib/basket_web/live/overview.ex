defmodule BasketWeb.Overview do
  use Surface.LiveView

  import BasketWeb.CoreComponents

  require Logger

  alias Basket.Alpaca.Websocket.{Client, Message}
  alias BasketWeb.Components.SearchInput

  prop tickers, :list, default: []

  def mount(_, _, socket) do
    BasketWeb.Endpoint.subscribe(Message.bars_topic())

    socket = assign(socket, tickers: [])
    socket = assign(socket, basket: [])

    {:ok, socket}
    # |> assign(:org, AsyncResult.loading())
    # |> start_async(:fetch_tickers, fn -> fetch_org!(id) end)}
  end

  def handle_event("ticker-search", %{"selected-ticker" => _query}, socket) do
    if length(socket.assigns.tickers) > 0 do
      {:noreply, socket}
    else
      {_status, tickers} =
        Cachex.fetch(:assets, "all", fn _key ->
          case Basket.Alpaca.HttpClient.list_assets() do
            {:ok, result} ->
              tickers =
                Enum.map(result, fn asset ->
                  asset["symbol"]
                end)

              {:commit, tickers}

            {:error, error} ->
              Logger.error("Could not fetch tickers", error: error.reason)
              {:ignore, []}
          end
        end)

      {:reply, %{}, assign(socket, :tickers, tickers)}
    end
  end

  def handle_event("ticker-add", %{"selected-ticker" => ticker}, socket) do
    :ok = Client.subscribe_to_market_data(%{bars: [ticker], quotes: [], trades: []})

    socket =
      case Basket.Alpaca.HttpClient.latest_quote(ticker) do
        {:ok, response} ->
          %{"bars" => %{^ticker => bars}} = response
          assign(socket, :basket, socket.assigns.basket ++ [Map.merge(bars, %{"S" => ticker})])

        {:error, error} ->
          Logger.error("Could not subscribe to ticker", reason: error.reason)
          socket
      end

    {:reply, %{}, socket}
  end

  def handle_event("ticker-remove", %{"ticker" => ticker}, socket) do
    :ok = Client.unsubscribe_to_market_data(%{bars: [ticker], quotes: [], trades: []})

    {:reply, %{},
     assign(socket, :basket, Enum.filter(socket.assigns.basket, fn t -> t["S"] != ticker end))}
  end

  def handle_event("ticker-update", message, socket) do
    IO.inspect("GOT IT CLIENT: #{inspect(message)}")
    {:noreply, socket}
  end

  def render(assigns) do
    ~F"""
    <.live_component module={SearchInput} id="stock-search-input" tickers={@tickers} />
    <.table id="ticker-list" rows={@basket}>
      <:col :let={ticker} label="ticker">{ticker["S"]}</:col>
      <:col :let={ticker} label="open">{ticker["o"]}</:col>
      <:col :let={ticker} label="high">{ticker["h"]}</:col>
      <:col :let={ticker} label="low">{ticker["l"]}</:col>
      <:col :let={ticker} label="close">{ticker["c"]}</:col>
      <:col :let={ticker} label="volume">{ticker["v"]}</:col>
      <:col :let={ticker} label="timestamp">{ticker["t"]}</:col>
      <:col :let={ticker} label="remove">
        <.button phx-click="ticker-remove" phx-value-ticker={ticker["S"]}>
          Remove
        </.button>
      </:col>
    </.table>
    """
  end
end

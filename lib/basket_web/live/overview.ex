defmodule BasketWeb.Overview do
  use Surface.LiveView

  import BasketWeb.CoreComponents

  require Logger

  alias Basket.Alpaca.Websocket
  alias BasketWeb.Components.SearchInput

  prop tickers, :list, default: []

  def mount(_, _, socket) do
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
    # subscribe to ticker
    Websocket.Client.subscribe_to_market_data(%{bars: [ticker], quotes: [], trades: []})
    {:reply, %{}, assign(socket, :basket, socket.assigns.basket ++ [ticker])}
  end

  def handle_event("ticker-remove", %{"ticker" => ticker}, socket) do
    {:reply, %{},
     assign(socket, :basket, Enum.filter(socket.assigns.basket, fn t -> t != ticker end))}
  end

  def render(assigns) do
    ~F"""
    <.live_component module={SearchInput} id="stock-search-input" tickers={@tickers} />
    <.table id="ticker-list" rows={@basket}>
      <:col :let={ticker} label="ticker">{ticker}</:col>
      <:col :let={ticker} label="remove">
        <.button phx-click="ticker-remove" phx-value-ticker={ticker}>
          Remove
        </.button>
      </:col>
    </.table>
    """
  end
end

defmodule BasketWeb.Overview do
  use Surface.LiveView

  import BasketWeb.CoreComponents

  require Logger

  alias Basket.Alpaca.Websocket.{Client, Message}
  alias BasketWeb.Components.SearchInput

  prop tickers, :list, default: []

  def mount(_, _, socket) do
    BasketWeb.Endpoint.subscribe(Message.bars_topic())

    IO.inspect("SOCKASH: #{inspect(socket)}")
    socket = assign(socket, tickers: [])
    socket = assign(socket, basket: [])

    {:ok, socket}
    # |> assign(:org, AsyncResult.loading())
    # |> start_async(:fetch_tickers, fn -> fetch_org!(id) end)}
  end

  def handle_event("ticker-search", %{"selected-ticker" => _query}, socket) do
    IO.inspect(socket, limit: :infinity)

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

          initial_bars = for {k, v} <- bars, into: %{}, do: {k, {v, ""}}

          assign(
            socket,
            :basket,
            socket.assigns.basket ++ [Map.merge(initial_bars, %{"S" => {ticker, ""}})]
          )

        {:error, error} ->
          Logger.error("Could not subscribe to ticker", reason: error.reason)
          socket
      end

    {:reply, %{}, socket}
  end

  def handle_event("ticker-remove", %{"ticker" => ticker}, socket) do
    :ok = Client.unsubscribe_to_market_data(%{bars: [ticker], quotes: [], trades: []})

    {:reply, %{},
     assign(
       socket,
       :basket,
       Enum.filter(socket.assigns.basket, fn t -> Enum.at(t["S"], 0) != ticker end)
     )}
  end

  # def handle_event("ticker-update", message, socket) do
  #   IO.inspect("GOT IT CLIENT: #{inspect(message)}")
  #   {:noreply, socket}
  # end

  # Test Message : "MESSAGEEEE: [{\"T\":\"b\",\"S\":\"AAPL\",\"o\":182.675,\"h\":182.73,\"l\":182.665,\"c\":182.73,\"v\":2802,\"t\":\"2023-11-08T20:25:00Z\",\"n\":36,\"vw\":182.694461}]"
  bars = %{
    "T" => "b",
    "S" => "AAPL",
    "o" => 82.675,
    "h" => 182.73,
    "l" => 182.665,
    "c" => 182.73,
    "v" => 2802,
    "t" => "2023-11-08T20:25:00Z",
    "n" => 36,
    "vw" => 182.694461
  }

  socket = %{
    assigns: %{
      __changed__: %{
        __context__: true
      },
      __context__: %{},
      flash: %{},
      live_action: nil,
      basket: [
        %{
          "S" => {"AAPL", ""},
          "c" => {182.89, ""},
          "h" => {182.99, ""},
          "l" => {182.89, ""},
          "n" => {412, ""},
          "o" => {182.935, ""},
          "t" => {"2023-11-08T20:59:00Z", ""},
          "v" => {43514, ""},
          "vw" => {182.956702, ""}
        }
      ]
    }
  }

  # BasketWeb.Overview.handle_info(%Phoenix.Socket.Broadcast{topic: "bars", event: "ticker-update", payload: bars}, socket)
  def handle_info(
        %Phoenix.Socket.Broadcast{topic: "bars", event: "ticker-update", payload: bars},
        socket
      ) do
    IO.inspect("HANDLE_INFO: #{inspect(bars)}")
    # Get the old ticker data
    old_ticker = Enum.find(socket.assigns.basket, fn t -> elem(t["S"], 0) == bars["S"] end)

    bars_with_changes =
      for {k, v} <- bars, into: %{} do
        if k in ["S", "T", "t", "n"] do
          {k, {v, ""}}
        else
          IO.inspect("K IS: #{k}")
          IO.inspect("DIFFDIR: #{diff_direction(old_ticker[k], bars[k])}")
          {k, {v, diff_direction(old_ticker[k], bars[k])}}
        end
      end

    IO.inspect(
      "HANDLE_INFO: #{inspect(socket.assigns.basket ++ [Map.merge(bars_with_changes, %{"S" => bars["S"]})])}"
    )

    new_basket =
      Enum.map(socket.assigns.basket, fn row ->
        if elem(row["S"], 0) == bars["S"],
          do: Map.merge(bars_with_changes, %{"S" => {bars["S"], ""}}),
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

  def render(assigns) do
    ~F"""
    <.live_component module={SearchInput} id="stock-search-input" tickers={@tickers} />
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
end

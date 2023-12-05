defmodule BasketWeb.Live.Overview do
  @moduledoc """
  Home page shows a list of assets and updates them in realtime via websockets.
  """
  use Surface.LiveView

  require Logger

  alias Basket.Tickers.Ticker
  alias Basket.Websocket.TickerAgent
  alias BasketWeb.Live.Overview.{Search, TickerAdd, TickerBar, TickerBarTable, TickerRow}
  alias BasketWeb.Components.NavRow
  alias BasketWeb.Presence

  on_mount {BasketWeb.Live.UserLiveAuth, :user}

  def mount(_, _, socket) do
    case Ticker.for_user(socket.assigns.user) do
      [] ->
        {:ok, assign(socket, basket: [])}

      assets ->
        tickers = Enum.map(assets, & &1.ticker)

        socket = track_new_assets(tickers, socket)
        Presence.track(self(), "connections", socket.assigns.user.id, %{tickers: tickers})

        {:ok, socket}
    end
  end

  def handle_info({"ticker-add", %{"ticker" => ticker}}, socket) do
    if ticker in tickers(socket) or String.trim(ticker) == "" do
      {:noreply, socket}
    else
      Ticker.add(socket.assigns.user, ticker)
      {:noreply, track_new_assets(ticker, socket)}
    end
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{topic: _topic, event: "ticker-update", payload: payload},
        socket
      ) do
    new_values = TickerRow.new(payload)
    IO.inspect(new_values, label: "BARS")

    new_basket =
      socket.assigns.basket
      |> Enum.find(&(&1.ticker.value == new_values.ticker.value))
      |> TickerRow.update(new_values)
      |> Map.from_struct()
      |> Enum.into([])

    # |> Map.to_list()

    {:noreply,
     assign(
       socket,
       :basket,
       new_basket
     )}
  end

  def handle_event("ticker-remove", %{"ticker" => ticker}, socket) do
    if ticker in tickers(socket) do
      :ok = BasketWeb.Endpoint.unsubscribe("bars-#{ticker}")

      # Presence.update(socket, "connections", socket.assigns.user.id, fn tickers ->
      #  Enum.filter(tickers, &(&1 != ticker))
      # end)

      :ok = TickerAgent.remove(ticker)

      Ticker.remove(socket.assigns.user, ticker)

      {:reply, %{},
       assign(
         socket,
         :basket,
         Enum.filter(socket.assigns.basket, fn t -> t.ticker.value != ticker end)
       )}
    else
      {:noreply, socket}
    end
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

  defp track_new_assets(tickers, socket) do
    case TickerAdd.call(tickers) do
      {:ok, {bar_rows, not_found_tickers}} ->
        socket =
          if not_found_tickers != [] do
            put_flash(
              socket,
              :info,
              "No data for tickers: #{Enum.join(not_found_tickers, ", ")}"
            )
          else
            socket
          end

        ticker_bars =
          Enum.map(bar_rows, fn bar_row -> new_ticker_row(%{}, Map.from_struct(bar_row)) end)
          |> Enum.sort_by(& &1.ticker.value)

        basket = if is_nil(socket.assigns[:basket]), do: [], else: socket.assigns.basket

        assign(socket, :basket, basket ++ ticker_bars)

      {:error, error} ->
        Logger.error("Could not subscribe to ticker: #{error}")
        put_flash(socket, :error, "Something when wrong.")
    end
  end

  defp new_ticker_row(old_row, new_row) when old_row == %{} do
    Enum.reduce(new_row, %{}, fn {k, v}, acc ->
      Map.put(acc, k, %TickerBar{value: v, prev_value: nil})
    end)
  end

  defp new_ticker_row(old_row, new_row) do
    Enum.reduce(new_row, %{}, fn {k, v}, acc ->
      Map.put(acc, k, %TickerBar{value: v, prev_value: nil})
    end)
  end

  defp tickers(socket), do: Enum.map(socket.assigns.basket, fn row -> row.ticker.value end)
end

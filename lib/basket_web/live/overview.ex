defmodule BasketWeb.Live.Overview do
  @moduledoc """
  Home page shows a list of assets and updates them in realtime via websockets.
  """
  use Surface.LiveView

  require Logger

  alias Basket.Tickers.Ticker
  alias BasketWeb.Live.Overview.{Search, TickerAdd, TickerBar, TickerBarTable, TickerRow}
  alias BasketWeb.Components.NavRow
  alias BasketWeb.Presence

  on_mount {BasketWeb.Live.UserLiveAuth, :user}

  def mount(_, _, socket) do
    if connected?(socket) do
      load_user_tickers(socket)
    else
      assign(socket, basket: [])
    end
  end

  def handle_info({"ticker-add", %{"ticker" => ticker}}, socket) do
    if ticker in tickers(socket) or String.trim(ticker) == "" do
      {:noreply, socket}
    else
      Ticker.add(socket.assigns.user, ticker)
      BasketWeb.Endpoint.subscribe("bars-#{ticker}")

      {:noreply, track_new_assets(ticker, socket)}
    end
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{topic: _topic, event: "ticker-update", payload: payload},
        socket
      ) do
    new_row = TickerRow.new(payload)

    new_basket =
      Enum.map(socket.assigns.basket, fn old_row ->
        if old_row.ticker.value == new_row.ticker.value do
          TickerRow.update(old_row, new_row)
        else
          old_row
        end
      end)

    {
      :noreply,
      assign(
        socket,
        :basket,
        new_basket
      )
    }
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
    if ticker in tickers(socket) do
      Ticker.remove(socket.assigns.user, ticker)
      IO.inspect("UNTRACK")
      Presence.untrack(self(), "bars-#{ticker}", socket.assigns.user.id)
      :ok = BasketWeb.Endpoint.unsubscribe("bars-#{ticker}")

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

  defp load_user_tickers(socket) do
    case Ticker.for_user(socket.assigns[:user]) do
      [] ->
        assign(socket, basket: [])

      assets ->
        tickers = Enum.map(assets, & &1.ticker)
        track_new_assets(tickers, socket)
    end
  end

  defp track_new_assets(tickers, socket) do
    case TickerAdd.call(tickers, socket.assigns.user.id) do
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
      Map.put(acc, k, %TickerBar{value: v.value, prev_value: old_row[k].value})
    end)
  end

  defp tickers(socket), do: Enum.map(socket.assigns.basket, fn row -> row.ticker.value end)
end

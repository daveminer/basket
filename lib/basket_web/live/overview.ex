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

  @initial_temp_assigns [basket: [], updated_row_id: nil]

  def mount(_, _, socket) do
    socket = assign(socket, :updated_row_id, "")

    if connected?(socket) do
      tickers = load_user_tickers(socket.assigns.user)

      result = TickerAdd.call(tickers, socket.assigns.user.id)
      new_socket = handle_ticker_add_result(result, socket)

      {:ok, new_socket, temporary_assigns: @initial_temp_assigns}
    else
      {:ok, socket, temporary_assigns: @initial_temp_assigns}
    end
  end

  def handle_info({"ticker-add", %{"ticker" => ticker}}, socket) do
    if ticker in tickers(socket) or String.trim(ticker) == "" do
      {:noreply, socket}
    else
      result = TickerAdd.call([ticker], socket.assigns.user.id)
      new_socket = handle_ticker_add_result(result, socket, add_method: :append)
      {:noreply, new_socket}
    end
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{topic: _topic, event: "ticker-update", payload: payload},
        socket
      ) do
    new_row = TickerRow.new(payload["S"], payload)

    new_row = Map.put(new_row, :data_updated, true)

    socket = assign(socket, :updated_row_id, new_row.ticker)

    updated_socket = update(socket, :basket, fn basket -> [new_row | basket] end)

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
    if ticker in tickers(socket) do
      Ticker.remove(socket.assigns.user, ticker)
      Presence.untrack(self(), "bars-#{ticker}", socket.assigns.user.id)

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

    # Determine how to add the new bars based on the `add_method` option
    new_basket =
      case Keyword.get(opts, :add_method) do
        :append -> socket.assigns.basket ++ bar_rows
        _ -> bar_rows |> Enum.sort_by(& &1.ticker)
      end

    assign(socket, :basket, new_basket)
  end

  defp handle_ticker_add_result({:error, error}, socket, _opts) do
    Logger.error("Could not subscribe to ticker: #{error}")
    socket
  end

  defp data_updated_attr(updated_row_id, row_id) do
    if updated_row_id == row_id, do: "data-updated=\"true\"", else: ""
  end

  defp tickers(socket), do: Enum.map(socket.assigns.basket, fn row -> row.ticker.value end)
end

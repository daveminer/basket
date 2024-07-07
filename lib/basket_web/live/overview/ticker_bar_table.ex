defmodule BasketWeb.Live.Overview.TickerBarTable do
  @moduledoc """
  Displays a collection of TickerRow components in a table.
  """

  use Phoenix.Component

  require Logger

  alias Basket.Http
  alias Basket.Http.Alpaca.Bars
  alias BasketWeb.{CoreComponents, Presence}

  @doc """
  Creates a row to be added to the ticker bar table. Deserializes the data into TickerBar instances
  before returning.
  """
  @spec add_ticker(list(String.t()) | String.t(), String.t()) ::
          {:ok, %{bars: list(Bars.t()), tickers_not_found: list(String.t())}}
          | {:error, String.t()}
  def add_ticker(tickers, user_id) when is_list(tickers) do
    ticker_list = Enum.join(tickers, ",")

    case Http.Alpaca.latest_quote(ticker_list) do
      {:ok, %{"bars" => bar_list}} ->
        bars = Enum.map(bar_list, fn {k, v} -> Bars.new(k, v) end)
        returned_tickers = Enum.map(bars, fn b -> b.ticker end)

        subscribe_to_tickers(returned_tickers, user_id)

        {:ok, %{bars: bars, tickers_not_found: tickers -- returned_tickers}}

      {:error, %{"message" => error}} ->
        {:error, error}
    end
  end

  def call(ticker, user_id), do: call([ticker], user_id)

  defp subscribe_to_tickers(tickers, user_id),
    do:
      Enum.each(tickers, fn ticker ->
        Presence.track(self(), "bars-#{ticker}", user_id, %{})

        case BasketWeb.Endpoint.subscribe("bars-#{ticker}") do
          :ok -> :ok
          {:error, error} -> Logger.error("Could not subscribe to ticker: #{error}")
        end
      end)

  def render(assigns) do
    ~H"""
    <div>
      <CoreComponents.table id={@id} rows={@rows} can_delete={@can_delete}>
        <:col :let={row} key="ticker" label="ticker"><%= row.ticker %></:col>
        <:col :let={row} key="open" label="open"><%= row.open %></:col>
        <:col :let={row} key="high" label="high"><%= row.high %></:col>
        <:col :let={row} key="low" label="low"><%= row.low %></:col>
        <:col :let={row} key="close" label="close"><%= row.close %></:col>
        <:col :let={row} key="volume" label="volume"><%= row.volume %></:col>
        <:col :let={row} key="timestamp" label="timestamp"><%= row.timestamp %></:col>

        <:col :let={row} :if={@can_delete}>
          <button
            class="btn btn-xs btn-circle btn-outline"
            phx-click="ticker-remove"
            phx-value-ticker={row.id}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-3 w-3"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </button>
        </:col>
      </CoreComponents.table>
    </div>
    """
  end
end

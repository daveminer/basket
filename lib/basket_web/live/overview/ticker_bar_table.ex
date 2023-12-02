defmodule BasketWeb.Live.Overview.TickerBarTable do
  @moduledoc """
  Allows the user to search for and add a ticker to the table. Will make an HTTP call
  if the ticker list is not populated, otherwise it will pull the list from the cache.
  """

  use Surface.Component

  alias BasketWeb.CoreComponents

  prop id, :string
  prop rows, :list, default: []

  def render(assigns) do
    ~F"""
    <div>
      <CoreComponents.table id={@id} rows={@rows}>
        <:col :let={row} key="ticker" label="ticker">{value_from_ticker_bar(row.ticker)}</:col>
        <:col :let={row} key="open" label="open">{value_from_ticker_bar(row.open)}</:col>
        <:col :let={row} key="high" label="high">{value_from_ticker_bar(row.high)}</:col>
        <:col :let={row} key="low" label="low">{value_from_ticker_bar(row.low)}</:col>
        <:col :let={row} key="close" label="close">{value_from_ticker_bar(row.close)}</:col>
        <:col :let={row} key="volume" label="volume">{value_from_ticker_bar(row.volume)}</:col>
        <:col :let={row} key="timestamp" label="timestamp">{value_from_ticker_bar(row.timestamp)}</:col>
        <:col :let={row} label="remove">
          <CoreComponents.button
            phx-click="ticker-remove"
            phx-value-ticker={value_from_ticker_bar(row.ticker)}
            class="bg-red-600"
          >
            X
          </CoreComponents.button>
        </:col>"
      </CoreComponents.table>
    </div>
    """
  end

  defp value_from_ticker_bar(nil), do: nil
  defp value_from_ticker_bar(ticker_bar), do: ticker_bar.value
end

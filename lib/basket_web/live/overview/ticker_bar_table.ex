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
        <:col :let={row} key="ticker" label="ticker">{row.ticker.value}</:col>
        <:col :let={row} key="open" label="open">{row.open.value}</:col>
        <:col :let={row} key="high" label="high">{row.high.value}</:col>
        <:col :let={row} key="low" label="low">{row.low.value}</:col>
        <:col :let={row} key="close" label="close">{row.close.value}</:col>
        <:col :let={row} key="volume" label="volume">{row.volume.value}</:col>
        <:col :let={row} key="timestamp" label="timestamp">{row.timestamp.value}</:col>
        <:col :let={row} label="remove">
          <CoreComponents.button
            phx-click="ticker-remove"
            phx-value-ticker={row.ticker.value}
            class="bg-red-600"
          >
            X
          </CoreComponents.button>
        </:col>"
      </CoreComponents.table>
    </div>
    """
  end
end

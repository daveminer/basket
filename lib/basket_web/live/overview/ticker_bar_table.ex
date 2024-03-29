defmodule BasketWeb.Live.Overview.TickerBarTable do
  @moduledoc """
  Displays a collection of TickerRow components in a table.
  """

  use Surface.Component

  alias BasketWeb.CoreComponents

  prop id, :string
  prop rows, :list, default: []

  def render(assigns) do
    ~F"""
    <div>
      <CoreComponents.table id={@id} rows={@rows}>
        <:col :let={row} key="ticker" label="ticker">{row.ticker}</:col>
        <:col :let={row} key="open" label="open">{row.open}</:col>
        <:col :let={row} key="high" label="high">{row.high}</:col>
        <:col :let={row} key="low" label="low">{row.low}</:col>
        <:col :let={row} key="close" label="close">{row.close}</:col>
        <:col :let={row} key="volume" label="volume">{row.volume}</:col>
        <:col :let={row} key="timestamp" label="timestamp">{row.timestamp}</:col>
        <:col :let={row} label="remove">
          <CoreComponents.button phx-click="ticker-remove" phx-value-ticker={row.id} class="bg-red-600">
            X
          </CoreComponents.button>
        </:col>
      </CoreComponents.table>
    </div>
    """
  end
end

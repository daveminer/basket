defmodule BasketWeb.Live.Overview.TickerBarTable do
  @moduledoc """
  Displays a collection of TickerRow components in a table.
  """

  use Phoenix.Component

  alias BasketWeb.CoreComponents

  def render(assigns) do
    ~H"""
    <div>
      <CoreComponents.table id={@id} rows={@rows}>
        <:col :let={row} key="ticker" label="ticker"><%= row.ticker %></:col>
        <:col :let={row} key="open" label="open"><%= row.open %></:col>
        <:col :let={row} key="high" label="high"><%= row.high %></:col>
        <:col :let={row} key="low" label="low"><%= row.low %></:col>
        <:col :let={row} key="close" label="close"><%= row.close %></:col>
        <:col :let={row} key="volume" label="volume"><%= row.volume %></:col>
        <:col :let={row} key="timestamp" label="timestamp"><%= row.timestamp %></:col>
        <:col :let={row}>
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

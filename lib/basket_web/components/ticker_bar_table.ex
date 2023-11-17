defmodule BasketWeb.Components.TickerBarTable do
  @moduledoc """
  Allows the user to search for and add a ticker to the table. Will make an HTTP call
  if the ticker list is not populated, otherwise it will pull the list from the cache.
  """

  use Surface.LiveComponent

  import BasketWeb.CoreComponents

  prop rows, :list, default: []

  attr :id, :string, required: true
  attr :class, :string, default: nil

  def mount(socket) do
    socket = assign(socket, basket: [])

    {:ok, socket}
  end

  def render(assigns) do
    ~F"""
    <div class="m-4">
      <.table id="ticker-list" rows={@rows}>
        <:col :let={ticker} key="S" label="ticker">{value_from_ticker_bar(ticker["S"])}</:col>
        <:col :let={ticker} key="o" label="open">{value_from_ticker_bar(ticker["o"])}</:col>
        <:col :let={ticker} key="h" label="high">{value_from_ticker_bar(ticker["h"])}</:col>
        <:col :let={ticker} key="l" label="low">{value_from_ticker_bar(ticker["l"])}</:col>
        <:col :let={ticker} key="c" label="close">{value_from_ticker_bar(ticker["c"])}</:col>
        <:col :let={ticker} key="v" label="volume">{value_from_ticker_bar(ticker["v"])}</:col>
        <:col :let={ticker} key="t" label="timestamp">{value_from_ticker_bar(ticker["t"])}</:col>
        <:col :let={ticker} label="">
          <.button
            phx-click="ticker-remove"
            phx-value-ticker={value_from_ticker_bar(ticker["S"])}
            class="bg-red-600 hover:bg-red-400"
          >
            X
          </.button>
        </:col>"
      </.table>
    </div>
    """
  end

  defp value_from_ticker_bar(ticker_bar), do: elem(ticker_bar, 0)
end

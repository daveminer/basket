defmodule BasketWeb.Components.SearchInput do
  @moduledoc """
  Allows the user to search for and add a ticker to the table. Will make an HTTP call
  if the ticker list is not populated, otherwise it will pull the list from the cache.
  """

  use Surface.LiveComponent

  import BasketWeb.CoreComponents

  prop tickers, :list, default: []

  attr :id, :string, required: true
  attr :class, :string, default: nil

  prop ticker_search_form, :string, default: ""

  def mount(socket) do
    form = to_form(%{"ticker_search_field" => ""})
    socket = assign(socket, :ticker_search_form, form)
    socket = assign(socket, :tickers, [])

    {:ok, socket}
  end

  def render(assigns) do
    ~F"""
    <div class="flex-row">
      <.inline_form for={@ticker_search_form} phx-change="ticker-search" phx-submit="ticker-add">
        <.input
          name="selected-ticker"
          value=""
          field={@ticker_search_form["ticker_search_field"]}
          list="tickers"
          phx-debounce="500"
          errors={["TODO"]}
        />

        <datalist id="tickers">
          {#for ticker <- @tickers}
            <option value={ticker}>{ticker}</option>
          {/for}
        </datalist>
        <:actions>
          <.button class="whitespace-nowrap">
            Add
          </.button>
        </:actions>
      </.inline_form>
    </div>
    """
  end
end

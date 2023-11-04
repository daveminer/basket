defmodule BasketWeb.Components.SearchInput do
  use Surface.LiveComponent

  import Phoenix.HTML.Form

  prop tickers, :list, default: []

  attr :id, :string, required: true
  attr :class, :string, default: nil

  attr :text, :string, default: ""

  def mount(socket) do
    {:ok, assign(socket, tickers: [])}
  end

  def render(assigns) do
    ~F"""
    <form phx-change="ticker-search" class="ticker-search-form">
      {text_input(:search_field, :query,
        autofocus: true,
        list: "tickers",
        "phx-debounce": "300"
      )}
      <datalist id="tickers">
        {#for ticker <- @tickers}
          <option value={ticker}>{ticker}</option>
        {/for}
      </datalist>
    </form>
    """
  end
end

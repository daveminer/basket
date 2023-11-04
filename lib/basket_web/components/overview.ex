defmodule BasketWeb.Components.Overview do
  use Surface.LiveComponent

  import BasketWeb.CoreComponents

  alias BasketWeb.Components.SearchInput

  prop rows, :list,
    default: [
      %{id: 1, username: "Johnnn"},
      %{id: 2, username: "Jane"}
    ]

  prop tickers, :list, default: []

  def mount(_, _, socket) do
    {:ok, assign(socket, tickers: [%{id: 1, username: "Johnnn"}, %{id: 2, username: "Jane"}])}
  end

  def render(assigns) do
    ~F"""
    <div>
    </div>
    """
  end
end

# <SearchInput.render id="stock-search-input" name="stock-search-input" tickers={@tickers}>
# </SearchInput.render>

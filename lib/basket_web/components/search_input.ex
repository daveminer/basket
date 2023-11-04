defmodule BasketWeb.Components.SearchInput do
  use Phoenix.Component

  import Phoenix.HTML.Form

  attr :id, :string, required: true
  attr :class, :string, default: nil
  attr :placeholder, :string, default: ""
  attr :text, :string, default: ""

  def render(assigns) do
    ~H"""
    <form phx-change="ticker-search" class="ticker-search-form">
      <%= text_input(:search_field, :query,
        placeholder: @placeholder,
        autofocus: true,
        "phx-debounce": "300"
      ) %>
    </form>
    """
  end
end

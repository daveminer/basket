defmodule BasketWeb.Components.SearchInput do
  @moduledoc """
  Allows the user to search for and add a ticker to the table. Will make an HTTP call
  if the ticker list is not populated, otherwise it will pull the list from the cache.
  """

  use Surface.LiveComponent

  require Logger

  import BasketWeb.CoreComponents

  alias Basket.Http

  attr :id, :string, required: true
  attr :class, :string, default: nil

  def mount(socket) do
    socket = assign(socket, :form, to_form(%{"search_value" => ""}))
    # socket = assign(socket, :ticker_search_value, "")
    socket = assign(socket, :tickers, [])

    {:ok, socket}
  end

  def update(_assigns, socket) do
    IO.inspect("SOCK BEF: #{inspect(socket)}")

    socket =
      assign(
        socket,
        :form,
        to_form(%{
          "search_value" => ""
        })
      )

    IO.inspect("SOCK: #{inspect(socket)}")

    {:ok, socket}
  end

  def handle_event("ticker-search", %{"selected_ticker" => _query}, socket) do
    if length(socket.assigns.tickers) > 0 do
      {:noreply, socket}
    else
      {_status, tickers} = Cachex.fetch(:assets, "all", fn _key -> load_tickers() end)

      {:reply, %{}, assign(socket, :tickers, tickers)}
    end
  end

  def render(assigns) do
    IO.inspect("TICK: #{inspect(assigns)}")

    ~F"""
    <div class="flex-row">
      <.inline_form for={assigns.form} phx-submit="ticker-add">
        <.input
          name="selected_ticker"
          field="search_value"
          value={assigns.form["search_value"].value}
          list="tickers"
          phx-change="ticker-search"
          phx-debounce="500"
          phx-target={@myself}
          errors={[]}
        />

        <datalist id="tickers">
          {#for ticker <- assigns.tickers}
            <option value={ticker}>{ticker}</option>
          {/for}
        </datalist>
        <:actions>
          <.button class="bg-green-600 whitespace-nowrap w-12">
            +
          </.button>
        </:actions>
      </.inline_form>
    </div>
    """
  end

  defp load_tickers do
    case Http.Alpaca.list_assets() do
      {:ok, result} ->
        tickers =
          Enum.map(result, fn asset ->
            asset["symbol"]
          end)

        {:commit, tickers}

      {:error, error} ->
        Logger.error("Could not fetch tickers: #{error}")

        {:ignore, []}
    end
  end
end

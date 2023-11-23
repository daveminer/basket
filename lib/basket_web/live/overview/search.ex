defmodule BasketWeb.Live.Overview.Search do
  @moduledoc """
  Allows the user to search for and add a ticker to the table. Will make an HTTP call
  if the ticker list is not populated, otherwise it will pull the list from the cache.
  """

  use Surface.LiveComponent

  require Logger

  alias Basket.Http
  alias Surface.Components.Form

  attr :id, :string, required: true
  attr :class, :string, default: nil

  data form, :map, default: %{"search_value" => ""}
  data tickers, :list, default: []

  def mount(socket) do
    socket = assign(socket, :form, %{"search_value" => ""})
    socket = assign(socket, :tickers, [])

    {:ok, socket}
  end

  # def update(_assigns, socket) do
  #   IO.inspect("SOCK BEF: #{inspect(socket)}")

  #   socket =
  #     assign(
  #       socket,
  #       :form,
  #       to_form(%{
  #         "search_value" => ""
  #       })
  #     )

  #   IO.inspect("SOCK: #{inspect(socket)}")

  #   {:ok, socket}
  # end

  def handle_event("ticker-add", %{"search_value" => ticker}, socket) do
    IO.inspect(ticker, label: "TICKER ADD")

    send(
      self(),
      {"ticker-add", %{"search_value" => ticker}}
    )

    IO.inspect(socket, label: "SOOOOOOO")
    {:reply, %{}, socket}
  end

  def handle_event("ticker-search", %{"search_value" => _query}, socket) do
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
    <div class="flex">
      <Form
        id="ticker-form"
        for={@form}
        change="ticker-search"
        submit="ticker-add"
        opts={phx_debounce: 500, autocomplete: "off", "phx-hook": "ClearInput", placeholder: "Search..."}
        class="flex flex-row-reverse"
      >
        <Form.TextInput
          id="ticker-input"
          field="search_value"
          value={@form["search_value"]}
          opts={list: "tickers"}
          class="mt-2 mb-2 m-2"
        />
        <datalist id="tickers">
          {#for ticker <- assigns.tickers}
            <option value={ticker}>{ticker}</option>
          {/for}
          <option value="" />
        </datalist>

        <button
          class={[
            "bg-green-600 whitespace-nowrap w-12",
            "phx-submit-loading:opacity-75 rounded-lg mt-2 mb-2 m-2",
            "text-sm font-semibold leading-6 text-white active:text-white/80"
          ]}
          type="submit"
        >
          +
        </button>
      </Form>
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

# <.inline_form for={assigns.form} phx-submit="ticker-add">
#   <.input
#     name="selected_ticker"
#     field="search_value"
#     value={assigns.form["search_value"].value}
#     list="tickers"
#     phx-change="ticker-search"
#     phx-debounce="500"
#     phx-target={@myself}
#     errors={[]}
#   />

#   <datalist id="tickers">
#     {#for ticker <- assigns.tickers}
#       <option value={ticker}>{ticker}</option>
#     {/for}
#   </datalist>
#   <:actions>
#     <.button class="bg-green-600 whitespace-nowrap w-12">
#       +
#     </.button>
#   </:actions>
# </.inline_form>

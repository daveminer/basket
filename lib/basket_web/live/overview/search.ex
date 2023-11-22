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

  def handle_event("ticker-add", %{"search_value" => _ticker}, socket) do
    IO.inspect("COMPSOCKET: #{inspect(socket.assigns)}")
    # basket_tickers = tickers(socket)

    # if ticker in basket_tickers or String.trim(ticker) == "" do
    #   {:noreply, socket}
    # else
    #   :ok = Websocket.Alpaca.subscribe(%{bars: [ticker], quotes: [], trades: []})

    #   socket =
    #     case Http.Alpaca.latest_quote(ticker) do
    #       {:ok, response} ->
    #         %{"bars" => ticker_bars} = response
    #         new_ticker_bars = Map.to_list(ticker_bars) |> List.first()
    #         initial_bars = build_ticker_bars(elem(new_ticker_bars, 1))

    #         assign(
    #           socket,
    #           :basket,
    #           socket.assigns.basket ++
    #             [Map.merge(initial_bars, %{"S" => %TickerBar{value: ticker}})]
    #         )

    #       {:error, error} ->
    #         Logger.error("Could not subscribe to ticker: #{error}")
    #         socket
    #     end
    IO.inspect(socket.assigns, label: "SOCKASN")

    send(
      self(),
      {"ticker-add", %{"selected_ticker" => ""}}
    )

    {:noreply, assign(socket, :form, %{"search_value" => ""})}
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
        for={@form}
        change="ticker-search"
        opts={phx_debounce: 500, autocomplete: "off", placeholder: "Search..."}
        submit="ticker-add"
        class="flex flex-row-reverse"
      >
        <Form.TextInput
          field="search_value"
          opts={list: "tickers"}
          value={@form["search_value"]}
          class="mt-2 mb-2 m-2"
        />
        <datalist id="tickers">
          {#for ticker <- assigns.tickers}
            <option value={ticker}>{ticker}</option>
          {/for}
        </datalist>

        <button class={[
          "bg-green-600 whitespace-nowrap w-12",
          "phx-submit-loading:opacity-75 rounded-lg mt-2 mb-2 m-2",
          "text-sm font-semibold leading-6 text-white active:text-white/80"
        ]}>
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

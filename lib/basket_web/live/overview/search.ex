defmodule BasketWeb.Live.Overview.Search do
  @moduledoc """
  Allows the user to search for and add a ticker to the table. Will make an HTTP call
  if the ticker list is not populated, otherwise it will pull the list from the cache.
  """

  use Phoenix.LiveComponent

  require Logger

  alias Basket.Http

  attr :id, :string, required: true
  attr :class, :string, default: nil

  def mount(socket) do
    socket = assign(socket, :form, %{"ticker" => ""})
    socket = assign(socket, :tickers, [])

    {:ok, socket}
  end

  def handle_event("ticker-add", %{"ticker" => ticker}, socket) do
    send(
      self(),
      {"ticker-add", %{"ticker" => ticker}}
    )

    socket = assign(socket, :form, %{"ticker" => ""})
    {:reply, %{}, socket}
  end

  def handle_event("ticker-search", %{"ticker" => ticker}, socket) do
    socket = assign(socket, :form, %{"ticker" => ticker})

    if length(socket.assigns.tickers) > 0 do
      {:noreply, socket}
    else
      {_status, tickers} = Cachex.fetch(:assets, "all", fn _key -> load_tickers() end)

      {:reply, %{}, assign(socket, :tickers, tickers)}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="flex">
      <.form
        :let={f}
        for={@form}
        phx-submit="ticker-add"
        phx-debounce="500"
        phx-change="ticker-search"
        phx-target={@myself}
        autocomplete="off"
        placeholder="Search..."
        class="flex flex-row-reverse items-center"
      >
        <input
          id="ticker-input"
          name="ticker"
          value={f["ticker"].value}
          list="tickers"
          type="text"
          class="input input-bordered mt-2 mb-2 m-2"
        />
        <datalist id="tickers">
          <%= for ticker <- assigns.tickers do %>
            <option value={ticker}><%= ticker %></option>
          <% end %>
          <option value="" />
        </datalist>
        <button class="btn btn-primary" type="submit">
          +
        </button>
      </.form>
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

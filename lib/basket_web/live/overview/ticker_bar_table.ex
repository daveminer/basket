defmodule BasketWeb.Live.Overview.TickerBarTable do
  @moduledoc """
  Displays a collection of TickerRow components in a table.
  """

  import BasketWeb.CoreComponents

  use Phoenix.Component

  require Logger

  alias Basket.Http
  alias Basket.Http.Alpaca.Bars
  alias BasketWeb.Presence

  @doc """
  Looks up the latest quote for the provided ticker(s) and subscribes to the
  Presence channel

  ## Parameters

    - `tickers`: The ticker(s) to add.
    - `user_id`: Get this from the socket.

  ## Returns

    - A map of Basket.Http.Alpaca.Bars and any tickers that were not found
      in the Alpaca API.
  """
  @spec add_ticker(list(String.t()) | String.t(), String.t()) ::
          {:ok, %{bars: list(Bars.t()), tickers_not_found: list(String.t())}}
          | {:error, String.t()}
  def add_ticker(tickers, user_id) when is_list(tickers) do
    ticker_list = Enum.join(tickers, ",")

    case Http.Alpaca.latest_quote(ticker_list) do
      {:ok, %{"bars" => bar_list}} ->
        bars = Enum.map(bar_list, fn {k, v} -> Bars.new(k, v) end)
        returned_tickers = Enum.map(bars, fn b -> b.ticker end)

        subscribe_to_tickers(returned_tickers, user_id)

        {:ok, %{bars: bars, tickers_not_found: tickers -- returned_tickers}}

      {:error, %{"message" => error}} ->
        {:error, error}
    end
  end

  def add_ticker(ticker, user_id), do: add_ticker([ticker], user_id)

  defp subscribe_to_tickers(tickers, user_id),
    do:
      Enum.each(tickers, fn ticker ->
        Presence.track(self(), "bars-#{ticker}", user_id, %{})

        case BasketWeb.Endpoint.subscribe("bars-#{ticker}") do
          :ok -> :ok
          {:error, error} -> Logger.error("Could not subscribe to ticker: #{error}")
        end
      end)

  def render(assigns) do
    ~H"""
    <div>
      <table id="ticker-table" class="table table-zebra">
        <thead>
          <tr>
            <th :for={col <- base_columns()} class="p-0 pb-4 text-center">
              <%= Atom.to_string(col) %>
            </th>
            <%= if @news != [] do %>
              <th class="p-0 pb-4 text-center">
                Sentiment
              </th>
            <% end %>
            <th></th>
          </tr>
        </thead>
        <tbody id={@id} phx-hook="CellValueStore" phx-update="replace" class="">
          <tr :for={row <- @rows} id={row.id} class="">
            <td
              :for={col <- base_columns()}
              data-key={"#{row.id}_#{Atom.to_string(col)}"}
              class={[
                "relative p-0",
                "text-center"
              ]}
            >
              <div class="block">
                <span id={"#{row.id}-#{Atom.to_string(col)}-content-slot"} class={}>
                  <%= Map.get(row, col) %>
                </span>
              </div>
            </td>
            <%= if @news != [] do %>
              <td data-key={"#{row.id}-sentiment"} class="text-center">
                <% sentiments = Map.get(@news, row.id) %>
                <div class="flex flex-row justify-center">
                  <span>
                    <div>
                      <.icon
                        name="hero-hand-thumb-up-solid"
                        class="h-5 w-5 opacity-40 hover:opacity-70"
                      />
                    </div>
                    <div>
                      <%= sentiments["positive"] %>
                    </div>
                  </span>
                  <span class="mx-4">
                    <div>
                      <.icon
                        name="hero-question-mark-circle-solid"
                        class="h-5 w-5 opacity-40 hover:opacity-70"
                      />
                    </div>
                    <div>
                      <%= sentiments["neutral"] %>
                    </div>
                  </span>
                  <span>
                    <div>
                      <.icon
                        name="hero-hand-thumb-down-solid"
                        class="h-5 w-5 opacity-40 hover:opacity-70"
                      />
                    </div>
                    <div>
                      <%= sentiments["negative"] %>
                    </div>
                  </span>
                </div>
              </td>
            <% end %>
            <td data-key={"#{row.id}-delete"}>
              <button phx-click="ticker-remove" phx-value-ticker={row.id}>
                <.icon name="hero-x-mark-solid" class="h-5 w-5 opacity-40 hover:opacity-70" />
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  defp base_columns, do: [:ticker, :open, :high, :low, :close, :volume, :timestamp]
end

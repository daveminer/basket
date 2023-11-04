defmodule BasketWeb.Overview do
  use Surface.LiveView

  require Logger

  alias BasketWeb.Components.Overview

  prop tickers, :list, default: []

  def mount(%{"id" => id}, _, socket) do
    {:ok,
     socket
     |> assign(:org, AsyncResult.loading())
     |> start_async(:fetch_tickers, fn -> fetch_org!(id) end)}
  end

  def handle_event("ticker-search", %{"search_field" => %{"query" => query}}, socket) do
    # IO.inspect("HANDLE EVENT: #{query}")

    {_status, tickers} =
      Cachex.fetch(:assets, "all", fn _key ->
        IO.inspect("REACTIVE")

        case Basket.Alpaca.HttpClient.list_assets() do
          {:ok, result} ->
            IO.inspect("OK")

            tickers =
              Enum.map(result, fn asset ->
                asset["symbol"]
              end)

            {:commit, tickers}

          {:error, error} ->
            IO.inspect("ERR:  #{inspect(error)}")
            Logger.error("Could not fetch tickers", error: error.reason)
            {:ignore, []}
        end
      end)

    IO.inspect("HERE: #{inspect(tickers)}")

    {:noreply, assign(socket, :tickers, tickers)}
  end

  def render(assigns) do
    ~F"""
    <Overview id="1" tickers={@tickers} />/>
    """
  end
end

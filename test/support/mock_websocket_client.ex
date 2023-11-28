defmodule Basket.Support.MockWebsocketClient do
  @moduledoc false

  require Logger

  def start_link(_state, _, _, _) do
    # Make the supervisor happy on test server startup
    IO.inspect("MOCKSTARTLINK")

    {:ok, self()}
  end

  def subscribe(_tickers) do
    :ok
  end

  def unsubscribe(_tickers) do
    :ok
  end
end

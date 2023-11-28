defmodule Basket.Support.MockWebsocketClient do
  @moduledoc false

  require Logger

  @doc """
  Satisfy the supervisor when the test application starts
  """
  def start_link(_state, _, _, _), do: {:ok, self()}

  def subscribe(_tickers), do: :not_implemented

  def unsubscribe(_tickers), do: :not_implemented
end

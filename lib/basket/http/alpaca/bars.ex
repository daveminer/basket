defmodule Basket.Http.Alpaca.Bars do
  @moduledoc """
  Typed instance of a stock chart bars.
  """

  @derive Jason.Encoder
  defstruct [:id, :ticker, :close, :open, :high, :low, :volume, :timestamp, :count, :vwap]

  @type t :: %__MODULE__{
          id: String.t(),
          ticker: String.t(),
          close: float,
          open: float,
          high: float,
          low: float,
          volume: integer,
          timestamp: DateTime.t(),
          count: integer,
          vwap: float
        }

  @doc ~S"""
  Create a new Bars instance from a ticker update message.
  The 'id' field is used for tracking updates in the LiveView stream.

  ## Example
    iex> new("AAA", %{"c" => 1.0, "h" => 1.0, "l" => 1.0, "n" => 1, "o" => 1.0, "t" => "2023-11-15T20:59:00Z", "v" => 1, "vw" => 1.0})
    %Bars{id: "AAA", ticker: "AAA", close: 1.0, open: 1.0, high: 1.0, low: 1.0, volume: 1, timestamp: ~U[2023-11-15 20:59:00Z], count: 1, vwap: 1.0}
  """
  @spec new(String.t(), map) :: t
  def new(ticker, %{
        "c" => close,
        "h" => high,
        "l" => low,
        "n" => count,
        "o" => open,
        "t" => timestamp,
        "v" => volume,
        "vw" => vwap
      }) do
    %__MODULE__{
      id: ticker,
      ticker: ticker,
      close: close,
      open: open,
      high: high,
      low: low,
      volume: volume,
      timestamp: timestamp,
      count: count,
      vwap: vwap
    }
  end
end

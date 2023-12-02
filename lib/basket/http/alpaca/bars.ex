defmodule Basket.Http.Alpaca.Bars do
  @moduledoc """
  Typed instance of a stock chart bars.
  """

  defstruct [:ticker, :close, :open, :high, :low, :volume, :timestamp, :count, :vwap]

  @type t :: %__MODULE__{
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

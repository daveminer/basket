defmodule BasketWeb.Live.Overview.TickerRow do
  @moduledoc """
  Data for a specific stock ticker.
  """

  defstruct [
    :id,
    :ticker,
    :close,
    :high,
    :low,
    :count,
    :open,
    :timestamp,
    :volume,
    :vwap
  ]

  @type t :: %__MODULE__{
          id: non_neg_integer(),
          ticker: String.t(),
          close: float(),
          high: float(),
          low: float(),
          count: integer(),
          open: float(),
          timestamp: DateTime.t(),
          volume: float(),
          vwap: float()
        }

  @doc """
  Converts a ticker-update message into a TickerRow

  ## Example
    iex> new_bars = %{"S" => "ALPHA", "T" => "t", "c" => 100, "h" => 105, "l" => 95, "n" => 1, "o" => 99, "t" => "2023-11-15T20:59:00Z", "v" => 50, "vw" => 51.1}
    iex> new(new_bars)
    %TickerRow{
      id: "ALPHA",
      close: 100,
      count: 1,
      high: 105,
      low: 95,
      open: 99,
      ticker: "ALPHA",
      timestamp: "2023-11-15T20:59:00Z",
      volume: 50,
      vwap: 51.1
    }
  """
  @spec new(payload :: map()) :: t()
  def new(%{
        "S" => ticker,
        "T" => _type,
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
      high: high,
      low: low,
      count: count,
      open: open,
      timestamp: timestamp,
      volume: volume,
      vwap: vwap
    }
  end
end

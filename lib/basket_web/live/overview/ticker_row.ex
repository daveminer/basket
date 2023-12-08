defmodule BasketWeb.Live.Overview.TickerRow do
  @moduledoc """
  Data for a specific ticker. Composed of TickerBars to visualize changes as
  bar messages are received.
  """
  alias BasketWeb.Live.Overview.TickerBar

  defstruct [
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

  @typedoc """
  Represents bar data for a specific ticker
  """
  @type t :: %__MODULE__{
          ticker: %TickerBar{},
          close: %TickerBar{},
          high: %TickerBar{},
          low: %TickerBar{},
          count: %TickerBar{},
          open: %TickerBar{},
          timestamp: %TickerBar{},
          volume: %TickerBar{},
          vwap: %TickerBar{}
        }

  @doc """
  Converts a ticker-update message into a TickerRow

  ## Example
    iex> new_bars = %{"S" => "AAPL", "T" => "t", "c" => 100, "h" => 105, "l" => 95, "n" => 1, "o" => 99, "t" => "2023-11-15T20:59:00Z", "v" => 50, "vw" => 51.1}
    iex> new(new_bars)
    %TickerRow{
              close: %TickerBar{value: 100, prev_value: nil},
              count: %TickerBar{value: 1, prev_value: nil},
              high: %TickerBar{value: 105, prev_value: nil},
              low: %TickerBar{value: 95, prev_value: nil},
              open: %TickerBar{value: 99, prev_value: nil},
              ticker: %TickerBar{value: "AAPL", prev_value: nil},
              timestamp: %TickerBar{value: "2023-11-15T20:59:00Z", prev_value: nil},
              volume: %TickerBar{value: 50, prev_value: nil},
              vwap: %TickerBar{value: 51.1, prev_value: nil}
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
      ticker: TickerBar.new(ticker),
      close: TickerBar.new(close),
      high: TickerBar.new(high),
      low: TickerBar.new(low),
      count: TickerBar.new(count),
      open: TickerBar.new(open),
      timestamp: TickerBar.new(timestamp),
      volume: TickerBar.new(volume),
      vwap: TickerBar.new(vwap)
    }
  end

  @doc """
  Converts a ticker-update message into a TickerRow

  ## Example

  iex> new_bars = build(:ticker_row_update)
  iex> old_ticker = build(:ticker_row)
  iex> update(old_ticker, new_bars)
  %TickerRow{
    close: %TickerBar{value: 101, prev_value: 100},
    count: %TickerBar{value: 2, prev_value: 1},
    high: %TickerBar{value: 113, prev_value: 105},
    low: %TickerBar{value: 93, prev_value: 95},
    open: %TickerBar{value: 100, prev_value: 99},
    ticker: %TickerBar{value: "XYZ", prev_value: "XYZ"},
    timestamp: %TickerBar{value: "2023-11-15T21:00:00Z", prev_value: "2023-11-15T20:59:00Z"},
    volume: %TickerBar{value: 24, prev_value: 50},
    vwap: %TickerBar{value: 33.3, prev_value: 51.1}
  }
  """
  @spec update(old_row :: TickerRow.t(), new_row :: TickerRow.t()) :: t()
  def update(old_row, new_row) do
    %__MODULE__{
      ticker: TickerBar.set(old_row.ticker, new_row.ticker.value),
      close: TickerBar.set(old_row.close, new_row.close.value),
      high: TickerBar.set(old_row.high, new_row.high.value),
      low: TickerBar.set(old_row.low, new_row.low.value),
      count: TickerBar.set(old_row.count, new_row.count.value),
      open: TickerBar.set(old_row.open, new_row.open.value),
      timestamp: TickerBar.set(old_row.timestamp, new_row.timestamp.value),
      volume: TickerBar.set(old_row.volume, new_row.volume.value),
      vwap: TickerBar.set(old_row.vwap, new_row.vwap.value)
    }
  end
end

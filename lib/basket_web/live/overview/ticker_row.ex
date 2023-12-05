defmodule BasketWeb.Live.Overview.TickerRow do
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
  """
  @spec update(old_row :: map(), new_row :: TickerRow.t()) :: t()
  def update(old_row, new_row) do
    %__MODULE__{
      ticker: TickerBar.set(new_row.ticker, old_row.ticker.value),
      close: TickerBar.set(new_row.close, old_row.close.value),
      high: TickerBar.set(new_row.high, old_row.high.value),
      low: TickerBar.set(new_row.low, old_row.low.value),
      count: TickerBar.set(new_row.count, old_row.count.value),
      open: TickerBar.set(new_row.open, old_row.open.value),
      timestamp: TickerBar.set(new_row.timestamp, old_row.timestamp.value),
      volume: TickerBar.set(new_row.volume, old_row.volume.value),
      vwap: TickerBar.set(new_row.vwap, old_row.vwap.value)
    }
  end
end

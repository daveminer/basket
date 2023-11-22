defmodule BasketWeb.Live.Overview.TickerBar do
  @moduledoc """
  Cell on the TickerBarTable.
  """
  alias __MODULE__

  defstruct value: nil, prev_value: nil

  @typedoc """
  This module is responsible for taking the data from an external call and updating the state of the cell.
  """
  @type t(value, prev_value) :: %TickerBar{
          value: value,
          prev_value: prev_value
        }

  @spec set_value(TickerBar.t(any(), any()), any()) :: TickerBar.t(any(), any())
  def set_value(ticker_bar, value) do
    %TickerBar{ticker_bar | value: value, prev_value: ticker_bar.value}
  end

  def change_direction(ticker_bar) do
    case change_value(ticker_bar) do
      x when x > 0 -> 1
      x when x < 0 -> -1
      _ -> 0
    end
  end

  @spec change_value(%{:prev_value => any() | nil, :value => any()}) :: integer()
  def change_value(%{value: value, prev_value: prev_value}) do
    if prev_value == nil or not (is_number(value) and is_number(prev_value)) do
      0
    else
      value - prev_value
    end
  end
end

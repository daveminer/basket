defmodule BasketWeb.Overview.TickerBar do
  @moduledoc """
  Stateful representation of a cell on the ticker bar table.
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

  @spec change_direction(TickerBar.t(any(), any())) :: integer()
  def change_direction(ticker_bar) do
    case change_value(ticker_bar) do
      x when x > 0 -> 1
      x when x < 0 -> -1
      _ -> 0
    end
  end

  @spec change_value(TickerBar.t(any(), any())) :: integer()
  def change_value(%{value: value, prev_value: prev_value}) do
    if is_number(value) and is_number(prev_value) do
      value - prev_value
    else
      0
    end
  end
end

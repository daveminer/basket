defmodule BasketWeb.Live.Overview.TickerBar do
  @moduledoc """
  Cell on the TickerBarTable.
  """
  alias __MODULE__

  defstruct value: nil, prev_value: nil

  @typedoc """
  This module takes the data from an external call and updates the state of the cell.
  """
  @type t(value, prev_value) :: %TickerBar{
          value: value,
          prev_value: prev_value
        }

  @doc ~S"""
  Sets a new value on a TickerBar. The prev_value is set to the current value for
  computing change direction.

  ## Example
      iex> set_value(%TickerBar{value: 1, prev_value: 0}, 2)
      %TickerBar{value: 2, prev_value: 1}
  """
  @spec set_value(TickerBar.t(any(), any()), any()) :: TickerBar.t(any(), any())
  def set_value(ticker_bar, value) do
    %TickerBar{ticker_bar | value: value, prev_value: ticker_bar.value}
  end

  @doc ~S"""
  Determines the change direction of the TickerBar based on the difference
  between the current value and the previous value.

  ## Example
      iex> change_direction(%TickerBar{value: 1, prev_value: 0})
      1
      iex> change_direction(%TickerBar{value: 0, prev_value: 0})
      0
      iex> change_direction(%TickerBar{value: 0, prev_value: 1})
      -1
  """
  @spec change_direction(%{prev_value: any(), value: any()}) :: -1 | 0 | 1
  def change_direction(ticker_bar) do
    case change_value(ticker_bar) do
      x when x > 0 -> 1
      x when x < 0 -> -1
      _ -> 0
    end
  end

  @doc ~S"""
  Return the value of the change between the current value and the previous value.
  Defaults to 0 if the value cannot be computed.

  ## Example
      iex> change_value(%TickerBar{value: 10, prev_value: 4})
      6
      iex> change_value(%TickerBar{value: 10, prev_value: 10})
      0
      iex> change_value(%TickerBar{value: 10, prev_value: nil})
      0
      iex> change_value(%TickerBar{value: "123", prev_value: 100})
      0
  """
  @spec change_value(%{:prev_value => any() | nil, :value => any()}) :: integer()
  def change_value(%{value: value, prev_value: prev_value}) do
    if prev_value == nil or not (is_number(value) and is_number(prev_value)) do
      0
    else
      value - prev_value
    end
  end
end

defmodule TickerAddTest do
  use ExUnit.Case, async: false

  import Basket.Factory
  alias BasketWeb.Live.Overview.TickerAdd

  doctest TickerAdd, import: true
end

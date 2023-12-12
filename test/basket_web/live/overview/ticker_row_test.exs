defmodule TickerRowTest do
  use ExUnit.Case, async: true

  import Basket.Factory
  import BasketWeb.Live.Overview.TickerRow

  alias BasketWeb.Live.Overview.{TickerBar, TickerRow}

  doctest BasketWeb.Live.Overview.TickerRow, import: true
end

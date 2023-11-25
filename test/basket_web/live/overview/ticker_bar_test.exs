defmodule TickerBarTest do
  use ExUnit.Case, async: true

  import BasketWeb.Live.Overview.TickerBar
  alias BasketWeb.Live.Overview.TickerBar

  doctest BasketWeb.Live.Overview.TickerBar, import: true
end

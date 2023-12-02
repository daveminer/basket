defmodule TickerAddTest do
  use ExUnit.Case, async: false

  alias BasketWeb.Live.Overview.{TickerAdd, TickerBar}

  doctest TickerAdd, import: true
end

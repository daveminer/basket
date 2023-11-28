defmodule TickerAddTest do
  use ExUnit.Case, async: true

  alias BasketWeb.Live.Overview.{TickerAdd, TickerBar}

  doctest TickerAdd, import: true
end

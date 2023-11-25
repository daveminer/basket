defmodule TickerAddTest do
  use ExUnit.Case, async: true

  alias BasketWeb.Live.Overview.{TickerAdd, TickerBar}

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  doctest TickerAdd, import: true
end

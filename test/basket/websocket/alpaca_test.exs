defmodule Basket.Websocket.AlpacaTest do
  use ExUnit.Case, async: true

  alias Basket.Websocket.Alpaca

  doctest Alpaca.Impl, import: true
end

defmodule Basket.Http.AlpacaTest do
  use ExUnit.Case, async: true

  alias Basket.Http.Alpaca

  doctest Alpaca.Impl, import: true
end

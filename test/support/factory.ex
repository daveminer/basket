defmodule Basket.Factory do
  @moduledoc false

  use ExMachina.Ecto

  alias Basket.Http.Alpaca.Bars

  def asset_mtcr_factory do
    %{
      "attributes" => [],
      "class" => "us_equity",
      "easy_to_borrow" => false,
      "exchange" => "OTC",
      "fractionable" => false,
      "id" => "0634e31f-2a61-4990-b713-a4be6d9eee49",
      "maintenance_margin_requirement" => 100,
      "marginable" => false,
      "name" => "METACRINE INC Common Stock",
      "shortable" => false,
      "status" => "active",
      "symbol" => "MTCR",
      "tradable" => false
    }
  end

  def asset_mtnoy_factory do
    %{
      "attributes" => [],
      "class" => "us_equity",
      "easy_to_borrow" => false,
      "exchange" => "OTC",
      "fractionable" => false,
      "id" => "ae2ab9f2-d2aa-4e7b-9ef8-2ffdf78ec0ff",
      "maintenance_margin_requirement" => 100,
      "marginable" => false,
      "name" => "MTN Group, Ltd. Sponsored American Depositary Receipt",
      "shortable" => false,
      "status" => "active",
      "symbol" => "MTNOY",
      "tradable" => false
    }
  end

  @spec new_bars_factory() :: Basket.Http.Alpaca.Bars.t()
  def new_bars_factory do
    Bars.new("XYZ", %{
      "c" => 187.15,
      "h" => 187.15,
      "l" => 187.05,
      "n" => 357,
      "o" => 187.11,
      "t" => "2023-11-15T20:59:00Z",
      "v" => 43_025,
      "vw" => 187.117416
    })
  end
end

defmodule BasketWeb.OverviewTest do
  use BasketWeb.ConnCase

  import Mox

  test "mount/3" do
    Basket.Websocket.MockAlpaca |> expect(:start_link, fn state -> {:ok, 1} end)

    Basket.Websocket.Alpaca.start_link("statee") |> IO.inspect(label: "RESULT")
  end
end

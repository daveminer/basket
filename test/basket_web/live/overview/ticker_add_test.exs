# defmodule TickerAddTest do
#   @moduledoc false

#   use ExUnit.Case, async: false

#   import Basket.Factory
#   import Mox

#   alias BasketWeb.Live.Overview.TickerAdd

#   setup :set_mox_global
#   setup :verify_on_exit!

#   test "reports when a ticker isn't found for subscription" do
#     parent = self()
#     ref = make_ref()

#     Mox.expect(Basket.Http.MockAlpaca, :latest_quote, fn _ ->
#       send(parent, {ref, :send_frame})
#       {:ok, %{"bars" => []}}
#     end)

#     task = Task.async(fn -> TickerAdd.call("ABC", 1) end)

#     assert Task.await(task) == {:ok, %{bars: [], tickers_not_found: ["ABC"]}}
#     assert_receive {^ref, :send_frame}
#   end

#   test "Adds a ticker to an empty set" do
#     parent = self()
#     ref = make_ref()

#     Mox.expect(Basket.Http.MockAlpaca, :latest_quote, fn _ ->
#       {:ok, %{"bars" => build(:bars_payload, ticker: "ABC")}}
#     end)

#     Mox.expect(Basket.Websocket.MockClient, :send_frame, 2, fn _, _ ->
#       send(parent, {ref, :send_frame})
#       :ok
#     end)

#     task = Task.async(fn -> TickerAdd.call("ABC", 1) end)

#     assert Task.await(task) == {:ok,
#                 %{
#                   bars: [
#                     %Basket.Http.Alpaca.Bars{
#                       id: "ABC",
#                       ticker: "ABC",
#                       close: 187.15,
#                       open: 187.11,
#                       high: 187.15,
#                       low: 187.05,
#                       volume: 43_025,
#                       timestamp: "2023-11-15T20:59:00Z",
#                       count: 357,
#                       vwap: 187.117416
#                     }
#                   ],
#                   tickers_not_found: []
#                 }}
#     for _ <- 1..2 do
#       assert_receive {^ref, :send_frame}
#     end
#   end

#   test "Adds two tickers to a set at once" do
#     parent = self()
#     ref = make_ref()

#     Mox.expect(Basket.Http.MockAlpaca, :latest_quote, fn _ ->
#       {:ok, %{"bars" => Map.merge(build(:bars_payload, ticker: "ABC"), build(:bars_payload))}}
#     end)

#     Mox.expect(Basket.Websocket.MockClient, :send_frame, 6, fn _, _ ->
#       # Let the test know that the mock was called
#       send(parent, {ref, :send_frame})
#       :ok
#     end)

#     task = Task.async(fn -> TickerAdd.call(["ABC", "ALPHA"], 1) end)

#     assert Task.await(task) == {:ok,
#                 %{
#                   bars: [
#                     %Basket.Http.Alpaca.Bars{
#                       id: "ABC",
#                       ticker: "ABC",
#                       close: 187.15,
#                       open: 187.11,
#                       high: 187.15,
#                       low: 187.05,
#                       volume: 43_025,
#                       timestamp: "2023-11-15T20:59:00Z",
#                       count: 357,
#                       vwap: 187.117416
#                     },
#                     %Basket.Http.Alpaca.Bars{
#                       id: "ALPHA",
#                       ticker: "ALPHA",
#                       close: 187.15,
#                       open: 187.11,
#                       high: 187.15,
#                       low: 187.05,
#                       volume: 43_025,
#                       timestamp: "2023-11-15T20:59:00Z",
#                       count: 357,
#                       vwap: 187.117416
#                     }
#                   ],
#                   tickers_not_found: []
#                 }}

#     for _ <- 1..6 do
#       assert_receive {^ref, :send_frame}
#     end
#   end
# end

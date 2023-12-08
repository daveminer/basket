defmodule BasketWeb.Live.OverviewTest do
  use BasketWeb.ConnCase, async: false

  require Phoenix.LiveViewTest

  import Basket.Factory
  import Mox

  alias BasketWeb.Live.Overview
  alias BasketWeb.Live.Overview.{Search, TickerBar, TickerRow}

  @assigns_map %{__changed__: %{__context__: true}, assigns: %{}}

  setup do
    # Shares the mock with the Cachex fallback function.
    Mox.set_mox_global()

    {:ok,
     %{
       bars: build(:new_bars),
       basket_with_row: [
         %TickerRow{
           ticker: %TickerBar{value: "XYZ", prev_value: "XYZ"},
           close: %TickerBar{value: 188.15, prev_value: 187.15},
           high: %TickerBar{value: 188.15, prev_value: 187.15},
           low: %TickerBar{value: 188.05, prev_value: 187.15},
           count: %TickerBar{value: 358, prev_value: 357},
           open: %TickerBar{value: 188.11, prev_value: 187.11},
           timestamp: %TickerBar{
             value: "2023-11-15T20:59:00Z",
             prev_value: "2023-11-15T20:58:00Z"
           },
           volume: %TickerBar{value: 43_031, prev_value: 43_025},
           vwap: %TickerBar{value: 188.117416, prev_value: 187.137416}
         }
       ]
     }}
  end

  describe "mount/3" do
    test "assigns empty lists to keys" do
      Basket.Websocket.MockClient |> expect(:start_link, fn _, _, _, _ -> {:ok, 1} end)

      assert({:ok, socket} = Overview.mount([], %{}, @assigns_map))

      assert(
        socket == %{
          __changed__: %{__context__: true, basket: true},
          __context__: %{},
          basket: [],
          assigns: %{}
        }
      )
    end
  end

  describe "handle_event/3 search" do
    test "ticker search does nothing without search criteria" do
      assert {:noreply, _socket} =
               Search.handle_event(
                 "ticker-search",
                 %{"ticker" => "ABC"},
                 Map.merge(@assigns_map, %{assigns: %{tickers: ["ABC", "XYZ"]}})
               )
    end

    test "ticker search does nothing if the ticker list is already populated" do
      assert {:noreply,
              %{
                __changed__: %{__context__: true},
                assigns: %{tickers: ["ABC", "XYZ"]}
              }} =
               Search.handle_event(
                 "ticker-search",
                 %{"ticker" => "XYZ"},
                 Map.merge(@assigns_map, %{assigns: %{tickers: ["ABC", "XYZ"]}})
               )
    end

    test "populates the ticker list with a web call if the cache is empty" do
      assets = [build(:asset_mtcr), build(:asset_mtnoy)]

      Basket.Http.MockAlpaca |> expect(:list_assets, fn -> {:ok, assets} end)

      assert {:reply, %{},
              %{
                __changed__: %{__context__: true, tickers: true},
                assigns: %{tickers: []}
              }} =
               Search.handle_event(
                 "ticker-search",
                 %{"ticker" => "XYZ"},
                 Map.merge(@assigns_map, %{assigns: %{tickers: []}})
               )
    end
  end

  describe "handle_event/3 add_ticker" do
    test "adds bars data to the liveview for the selected ticker", %{bars: bars} do
      Basket.Http.MockAlpaca
      |> expect(:latest_quote, fn _ -> {:ok, %{"bars" => bars}} end)

      Basket.Websocket.MockClient |> expect(:start_link, fn _, _, _, _ -> {:ok, self()} end)
      Basket.Websocket.MockClient |> expect(:send_frame, fn _, _ -> :ok end)

      assert {:reply, %{},
              %{
                __changed__: %{__context__: true, form: true},
                assigns: %{tickers: [], form: []},
                form: %{"ticker" => ""}
              }} =
               Search.handle_event(
                 "ticker-add",
                 %{"ticker" => "XYZ"},
                 Map.merge(@assigns_map, %{assigns: %{tickers: [], form: []}})
               )
    end

    test "does nothing if no ticker is provided" do
      assert {:reply, %{},
              %{
                __changed__: %{__context__: true, form: true},
                assigns: %{basket: [], tickers: []},
                form: %{"ticker" => ""}
              }} =
               Search.handle_event(
                 "ticker-add",
                 %{"ticker" => ""},
                 Map.merge(@assigns_map, %{assigns: %{tickers: [], basket: []}})
               )
    end

    test "does nothing if the ticker is already present", %{basket_with_row: basket_with_row} do
      assert {:reply, %{},
              %{
                __changed__: %{__context__: true},
                assigns: %{tickers: [], basket: [_bars]}
              }} =
               Search.handle_event(
                 "ticker-add",
                 %{"ticker" => "XYZ"},
                 Map.merge(@assigns_map, %{
                   assigns: %{
                     tickers: [],
                     basket: basket_with_row
                   }
                 })
               )
    end
  end

  describe "handle_event/3 remove_ticker" do
    test "removes a ticker if it is present in the liveview", %{
      bars: bars,
      basket_with_row: basket_with_row
    } do
      Basket.Http.MockAlpaca |> expect(:latest_quote, fn _ -> {:ok, %{"bars" => bars}} end)
      Basket.Websocket.MockClient |> expect(:send_frame, fn _, _ -> :ok end)

      assert {:reply, %{},
              %{
                __changed__: %{__context__: true, basket: true},
                assigns: %{tickers: [], basket: ^basket_with_row},
                basket: []
              }} =
               Overview.handle_event(
                 "ticker-remove",
                 %{"ticker" => "XYZ"},
                 Map.merge(@assigns_map, %{
                   assigns: %{tickers: [], basket: basket_with_row, user: %{id: 1}}
                 })
               )
    end

    test "does nothing if no ticker is provided" do
      assert {:noreply,
              %{
                __changed__: %{__context__: true},
                assigns: %{tickers: [], basket: []}
              }} =
               Overview.handle_event(
                 "ticker-remove",
                 %{"ticker" => ""},
                 Map.merge(@assigns_map, %{assigns: %{tickers: [], basket: []}})
               )
    end

    test "does nothing if the ticker is not in the liveview" do
      assert {:noreply,
              %{
                __changed__: %{__context__: true},
                assigns: %{tickers: [], basket: []}
              }} =
               Overview.handle_event(
                 "ticker-remove",
                 %{"ticker" => "XYZ"},
                 Map.merge(@assigns_map, %{
                   assigns: %{
                     tickers: [],
                     basket: []
                   }
                 })
               )
    end
  end

  describe "handle_info/3 ticker update" do
    test "processes a message with new bars", %{
      basket_with_row: basket_with_row
    } do
      assert {
               :noreply,
               %{
                 __changed__: %{__context__: true},
                 assigns: %{
                   basket: ^basket_with_row,
                   tickers: []
                 },
                 basket: [
                   %BasketWeb.Live.Overview.TickerRow{
                     ticker: %BasketWeb.Live.Overview.TickerBar{value: "XYZ", prev_value: "XYZ"},
                     close: %BasketWeb.Live.Overview.TickerBar{value: 188.15, prev_value: 187.15},
                     high: %BasketWeb.Live.Overview.TickerBar{value: 188.15, prev_value: 187.15},
                     low: %BasketWeb.Live.Overview.TickerBar{value: 188.05, prev_value: 187.15},
                     count: %BasketWeb.Live.Overview.TickerBar{value: 358, prev_value: 357},
                     open: %BasketWeb.Live.Overview.TickerBar{value: 188.11, prev_value: 187.11},
                     timestamp: %BasketWeb.Live.Overview.TickerBar{
                       value: "2023-11-15T20:59:00Z",
                       prev_value: "2023-11-15T20:58:00Z"
                     },
                     volume: %BasketWeb.Live.Overview.TickerBar{value: 43031, prev_value: 43025},
                     vwap: %BasketWeb.Live.Overview.TickerBar{
                       value: 188.117416,
                       prev_value: 187.137416
                     }
                   }
                 ]
               }
             } =
               Overview.handle_info(
                 %Phoenix.Socket.Broadcast{
                   topic: "bars",
                   event: "ticker-update",
                   payload: %{
                     "S" => %TickerBar{value: "AAPL", prev_value: nil},
                     "T" => %TickerBar{value: "b", prev_value: nil},
                     "c" => %TickerBar{value: 191.285, prev_value: nil},
                     "h" => %TickerBar{value: 191.37, prev_value: nil},
                     "l" => %TickerBar{value: 191.23, prev_value: nil},
                     "n" => %TickerBar{value: 50, prev_value: nil},
                     "o" => %TickerBar{value: 191.23, prev_value: nil},
                     "t" => %TickerBar{
                       value: "2023-11-20T16:24:00Z",
                       prev_value: nil
                     },
                     "v" => %TickerBar{value: 5433, prev_value: nil},
                     "vw" => %TickerBar{value: 191.328043, prev_value: nil}
                   }
                 },
                 Map.merge(@assigns_map, %{
                   assigns: %{tickers: [], basket: basket_with_row},
                   basket: basket_with_row
                 })
               )
    end
  end
end

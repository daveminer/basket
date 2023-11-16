defmodule BasketWeb.OverviewTest do
  use BasketWeb.ConnCase, async: false

  require Phoenix.LiveViewTest

  import Mox

  alias BasketWeb.Overview

  @assigns_map %{__changed__: %{__context__: true}}

  setup do
    # Will share the mock with the Cachex fallback.
    Mox.set_mox_global()

    {:ok,
     %{
       bars: %{
         "XYZ" => %{
           "c" => 188.15,
           "h" => 188.15,
           "l" => 188.05,
           "n" => 358,
           "o" => 188.11,
           "t" => "2023-11-15T20:59:00Z",
           "v" => 43031,
           "vw" => 188.117416
         }
       }
     }}
  end

  describe "mount/3" do
    test "assigns empty lists to keys" do
      Basket.Websocket.MockAlpaca |> expect(:start_link, fn state -> {:ok, 1} end)

      assert({:ok, socket} = Overview.mount([], %{}, @assigns_map))

      assert(
        socket == %{
          __changed__: %{__context__: true, basket: true, tickers: true},
          __context__: %{},
          basket: [],
          tickers: []
        }
      )
    end
  end

  describe "handle_event/3 search" do
    test "ticker search does nothing without search criteria" do
      assert {:noreply, socket} =
               Overview.handle_event(
                 "ticker-search",
                 %{"selected-ticker" => "ABC"},
                 Map.merge(@assigns_map, %{assigns: %{tickers: ["ABC", "XYZ"]}})
               )
    end

    test "ticker search does nothing if the ticker list is already populated" do
      assert {:noreply,
              %{
                __changed__: %{__context__: true},
                assigns: %{tickers: ["ABC", "XYZ"]}
              }} =
               Overview.handle_event(
                 "ticker-search",
                 %{"selected-ticker" => "XYZ"},
                 Map.merge(@assigns_map, %{assigns: %{tickers: ["ABC", "XYZ"]}})
               )
    end

    test "populates the ticker list with a web call if the cache is empty" do
      Basket.Http.MockAlpaca
      |> expect(:list_assets, fn ->
        {:ok,
         [
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
           },
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
         ]}
      end)

      assert {:reply, %{},
              %{
                __changed__: %{__context__: true, tickers: true},
                assigns: %{tickers: []}
              }} =
               Overview.handle_event(
                 "ticker-search",
                 %{"selected-ticker" => "XYZ"},
                 Map.merge(@assigns_map, %{assigns: %{tickers: []}})
               )
    end
  end

  describe "handle_event/3 add_ticker" do
    test "adds bars data to the liveview for the selected ticker", %{bars: bars} do
      expect(Basket.Http.MockAlpaca, :latest_quote, fn _ -> {:ok, %{"bars" => bars}} end)
      expect(Basket.Websocket.MockAlpaca, :subscribe, fn _ticker_subs -> :ok end)

      assert {:reply, %{},
              %{
                __changed__: %{__context__: true, basket: true},
                assigns: %{tickers: [], basket: []},
                basket: [bars]
              }} =
               Overview.handle_event(
                 "ticker-add",
                 %{"selected-ticker" => "XYZ"},
                 Map.merge(@assigns_map, %{assigns: %{tickers: [], basket: []}})
               )
    end

    test "does nothing if no ticker is provided" do
      # expect(Basket.Http.MockAlpaca, :latest_quote, fn _ -> {:ok, %{"bars" => bars}} end)
      # expect(Basket.Websocket.MockAlpaca, :subscribe, fn _ticker_subs -> :ok end)

      assert {:noreply,
              %{
                __changed__: %{__context__: true},
                assigns: %{tickers: [], basket: []}
              }} =
               Overview.handle_event(
                 "ticker-add",
                 %{"selected-ticker" => ""},
                 Map.merge(@assigns_map, %{assigns: %{tickers: [], basket: []}})
               )
    end

    test "does nothing if the ticker is already present" do
      basket_with_row = [
        %{
          "S" => {"XYZ", ""},
          "c" => {188.15, ""},
          "h" => {188.15, ""},
          "l" => {188.05, ""},
          "n" => {358, ""},
          "o" => {188.11, ""},
          "t" => {"2023-11-15T20:59:00Z", ""},
          "v" => {43031, ""},
          "vw" => {188.117416, ""}
        }
      ]

      assert {:noreply,
              %{
                __changed__: %{__context__: true},
                assigns: %{tickers: [], basket: [bars]}
              }} =
               Overview.handle_event(
                 "ticker-add",
                 %{"selected-ticker" => "XYZ"},
                 Map.merge(@assigns_map, %{
                   assigns: %{
                     tickers: [],
                     basket: basket_with_row
                   }
                 })
               )
    end
  end
end

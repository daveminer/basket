defmodule BasketWeb.OverviewTest do
  use BasketWeb.ConnCase

  require Phoenix.LiveViewTest

  import Mox

  alias BasketWeb.Overview

  @assigns_map %{__changed__: %{__context__: true}}
  @socket %{
    assigns: @assigns_map,
    __context__: %{},
    flash: %{},
    live_action: nil
  }

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

  describe "handle_event/3" do
    test "ticker search does nothing without search criteria" do
      assert {:noreply, socket} =
               Overview.handle_event(
                 "ticker-search",
                 %{"selected-ticker" => "ABC"},
                 Map.merge(@assigns_map, %{assigns: %{tickers: ["ABC", "XYZ"]}})
               )
    end

    # test "ticker search updates the ticker list" do
    #   assert {:reply, %{}, socket} =
    #            Overview.handle_event(
    #              "ticker-search",
    #              %{"selected-ticker" => "XYZ"},
    #              Map.merge(@assigns_map, %{assigns: %{tickers: ["ABC", "XYZ"]}})
    #            )

    #   assert socket == %{
    #            __changed__: %{__context__: true, tickers: true},
    #            __context__: %{},
    #            tickers: ["XYZ"]
    #          }
    # end
  end
end

defmodule BasketWeb.PresenceTest do
  @moduledoc false

  use ExUnit.Case, async: false

  import Mox

  alias BasketWeb.Presence

  doctest BasketWeb.Presence

  setup do
    {:ok, %{state: %{}}}
  end

  describe "handle_metas/4" do
    test "should subscribe to the ticker feed when a user joins an empty channel", %{
      state: state
    } do
      Basket.Websocket.MockClient
      |> expect(:send_frame, 2, fn _, _ ->
        :ok
      end)

      assert {:ok, _state} =
               Presence.handle_metas(
                 "bars-ABC",
                 %{
                   joins: %{"1" => %{metas: [%{phx_ref: "F5-vJ_d1tq0argHC"}]}},
                   leaves: %{}
                 },
                 %{"1" => [%{phx_ref: "F5-vJ_d1tq0argHC"}]},
                 state
               )

      verify!()
    end

    test "does not subscribe to the ticker feed when a user joins a populated channel", %{
      state: state
    } do
      expect(Basket.Websocket.MockClient, :send_frame, 0, fn _, _ -> :ok end)

      assert {:ok, _state} =
               Presence.handle_metas(
                 "bars-ABC",
                 %{
                   joins: %{"1" => %{metas: [%{phx_ref: "F5-vJ_d1tq0argHC"}]}},
                   leaves: %{}
                 },
                 %{
                   "1" => [%{phx_ref: "F5-vJ_d1tq0argHC"}],
                   "2" => [%{phx_ref: "F5-vJ_d1tq0argHC"}]
                 },
                 state
               )

      verify!()
    end

    test "should unsubscribe from the ticker feed when the last user leaves a channel", %{
      state: state
    } do
      Basket.Websocket.MockClient
      |> expect(:send_frame, 2, fn _, _ -> :ok end)

      assert {:ok, _state} =
               Presence.handle_metas(
                 "bars-ABC",
                 %{
                   joins: %{},
                   leaves: %{"1" => %{metas: [%{phx_ref: "F5-vJ_d1tq0argHC"}]}}
                 },
                 %{},
                 state
               )

      verify!()
    end

    test "does not unsubscribe to the ticker feed when a user leaves a channel with users still inside",
         %{
           state: state
         } do
      expect(Basket.Websocket.MockClient, :send_frame, 0, fn _, _ -> :ok end)

      assert {:ok, _state} =
               Presence.handle_metas(
                 "bars-ABC",
                 %{
                   joins: %{},
                   leaves: %{"1" => %{metas: [%{phx_ref: "F5-vJ_d1tq0argHC"}]}}
                 },
                 %{"2" => [%{phx_ref: "F5-vJ_d1tq0argHC"}]},
                 state
               )

      verify!()
    end
  end
end

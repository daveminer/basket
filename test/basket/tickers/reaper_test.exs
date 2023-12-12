defmodule Basket.Tickers.ReaperTest do
  use ExUnit.Case, async: true

  alias Basket.Tickers.Reaper

  describe "monitor/1" do
    test "adds the user to tracking" do
      assert :ok == Reaper.monitor("phx-test")
    end
  end

  describe "demonitor/0" do
    test "removes the user from tracking" do
      Reaper.monitor("phx-test")
      assert :ok == Reaper.demonitor()
    end
  end
end

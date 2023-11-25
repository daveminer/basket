defmodule Basket.Http.AlpacaTest do
  use ExUnit.Case, async: false

  import Basket.Factory

  alias Basket.Http.Alpaca

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "latest_quote" do
    test "returns the latest quote for the ticker", %{bypass: bypass} do
      new_bars = build(:new_bars)

      Bypass.expect_once(bypass, "GET", "/v2/stocks/bars/latest", fn conn ->
        Plug.Conn.resp(conn, 200, Jason.encode!(new_bars))
      end)

      config = Application.get_env(:basket, :alpaca)
      config = Keyword.put(config, :data_http_url, "http://localhost:#{bypass.port}")
      Application.put_env(:basket, :alpaca, config)

      assert {
               :ok,
               ^new_bars
             } = Alpaca.Impl.latest_quote("XYZ")
    end
  end

  describe "list_assets" do
    test "return the list of selectable assets", %{bypass: bypass} do
      assets = [build(:asset_mtcr), build(:asset_mtnoy)]

      Bypass.expect_once(bypass, "GET", "/v2/stocks/bars/latest", fn conn ->
        Plug.Conn.resp(conn, 200, Jason.encode!(assets))
      end)

      config = Application.get_env(:basket, :alpaca)
      config = Keyword.put(config, :data_http_url, "http://localhost:#{bypass.port}")
      Application.put_env(:basket, :alpaca, config)

      assert {
               :ok,
               ^assets
             } = Alpaca.Impl.latest_quote("XYZ")
    end
  end
end

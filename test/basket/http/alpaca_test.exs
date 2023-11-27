defmodule Basket.Http.AlpacaTest do
  use ExUnit.Case, async: false

  import Basket.Factory

  alias Basket.Http.Alpaca

  describe "latest_quote" do
    test "returns the latest quote for the ticker" do
      new_bars = build(:new_bars)

      TestServer.add("/v2/stocks/bars/latest",
        via: :get,
        to: fn conn ->
          Plug.Conn.resp(conn, 200, Jason.encode!(new_bars))
        end
      )

      config = Application.get_env(:basket, :alpaca)
      config = Keyword.put(config, :data_http_url, TestServer.url())
      Application.put_env(:basket, :alpaca, config)

      assert {
               :ok,
               ^new_bars
             } = Alpaca.Impl.latest_quote("XYZ")
    end
  end

  describe "list_assets" do
    test "return the list of selectable assets" do
      assets = [build(:asset_mtcr), build(:asset_mtnoy)]

      TestServer.add("/v2/assets",
        via: :get,
        to: fn conn ->
          Plug.Conn.resp(conn, 200, Jason.encode!(assets))
        end
      )

      config = Application.get_env(:basket, :alpaca)
      config = Keyword.put(config, :market_http_url, TestServer.url())
      Application.put_env(:basket, :alpaca, config)

      assert {
               :ok,
               ^assets
             } = Alpaca.Impl.list_assets()
    end
  end
end

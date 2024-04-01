defmodule Basket.Factory do
  @moduledoc false

  use ExMachina.Ecto

  alias Basket.Http.Alpaca.Bars
  alias Basket.Users.User
  alias BasketWeb.Live.Overview.TickerRow

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

  def bars_payload_factory(attrs) do
    ticker =
      if attrs[:ticker] do
        attrs.ticker
      else
        "ALPHA"
      end

    %{
      ticker => %{
        "c" => 187.15,
        "h" => 187.15,
        "l" => 187.05,
        "n" => 357,
        "o" => 187.11,
        "t" => "2023-11-15T20:59:00Z",
        "v" => 43_025,
        "vw" => 187.117416
      }
    }
  end

  def socket_factory do
    # %Phoenix.Socket{
    #   assigns: %{},
    #   channel: BasketWeb.TickerChannel,
    #   channel_pid: self(),
    #   endpoint: BasketWeb.Endpoint,
    #   handler: BasketWeb.UserSocket,
    #   id: nil,
    #   join_ref: "1",
    #   joined: true,
    #   private: %{},
    #   pubsub_server: Basket.PubSub,
    #   ref: nil,
    #   serializer: Jason,
    #   topic: "topic",
    #   transport: :websocket,
    #   transport_pid: self()
    # }

    %Phoenix.LiveView.Socket{
      assigns: %{__changed__: %{}},
      endpoint: BasketWeb.Endpoint,
      id: "1",
      parent_pid: nil,
      root_pid: self(),
      router: BasketWeb.Router,
      view: BasketWeb.OverviewLive
    }
  end

  def ticker_row_factory do
    %TickerRow{
      ticker: "XYZ",
      close: 100,
      high: 105,
      low: 95,
      count: 1,
      open: 99,
      timestamp: "2023-11-15T20:59:00Z",
      volume: 50,
      vwap: 51.1
    }
  end

  def ticker_row_update_factory do
    %TickerRow{
      ticker: "XYZ",
      close: 101,
      high: 113,
      low: 93,
      count: 2,
      open: 100,
      timestamp: "2023-11-15T21:00:00Z",
      volume: 24,
      vwap: 33.3
    }
  end

  def user_factory do
    %User{
      id: 1,
      email: "<EMAIL>"
    }
  end
end

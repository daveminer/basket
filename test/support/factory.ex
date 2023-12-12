defmodule Basket.Factory do
  @moduledoc false

  use ExMachina.Ecto

  alias Basket.Http.Alpaca.Bars
  alias Basket.Users.User
  alias BasketWeb.Live.Overview.{TickerBar, TickerRow}

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
        "XYZ"
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

  @spec new_bars_factory() :: Bars.t()
  def new_bars_factory do
    Bars.new("XYZ", %{
      "c" => 187.15,
      "h" => 187.15,
      "l" => 187.05,
      "n" => 357,
      "o" => 187.11,
      "t" => "2023-11-15T20:59:00Z",
      "v" => 43_025,
      "vw" => 187.117416
    })
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
      ticker: %TickerBar{value: "XYZ", prev_value: nil},
      close: %TickerBar{value: 100, prev_value: nil},
      high: %TickerBar{value: 105, prev_value: nil},
      low: %TickerBar{value: 95, prev_value: nil},
      count: %TickerBar{value: 1, prev_value: nil},
      open: %TickerBar{value: 99, prev_value: nil},
      timestamp: %TickerBar{value: "2023-11-15T20:59:00Z", prev_value: nil},
      volume: %TickerBar{value: 50, prev_value: nil},
      vwap: %TickerBar{value: 51.1, prev_value: nil}
    }
  end

  def ticker_row_update_factory do
    %TickerRow{
      ticker: %TickerBar{value: "XYZ", prev_value: nil},
      close: %TickerBar{value: 101, prev_value: nil},
      high: %TickerBar{value: 113, prev_value: nil},
      low: %TickerBar{value: 93, prev_value: nil},
      count: %TickerBar{value: 2, prev_value: nil},
      open: %TickerBar{value: 100, prev_value: nil},
      timestamp: %TickerBar{value: "2023-11-15T21:00:00Z", prev_value: nil},
      volume: %TickerBar{value: 24, prev_value: nil},
      vwap: %TickerBar{value: 33.3, prev_value: nil}
    }
  end

  def user_factory do
    %User{
      id: 1,
      email: "<EMAIL>"
    }
  end
end

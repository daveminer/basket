defmodule Basket.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Basket.Repo

  alias Basket.{Club, ClubTicker, News, Ticker, User}
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

  def club_factory do
    %Club{
      name: sequence(:ticker, &"Club#{&1}")
    }
  end

  def club_ticker_factory(opts) do
    ticker = opts[:ticker] || insert(:ticker)
    club = opts[:club] || insert(:club)

    %ClubTicker{
      ticker: ticker,
      club_id: club.id
    }
  end

  def news_factory do
    %News{
      headline:
        "Apple Leader in Phone Sales in China for Second Straight Month in November With 23.6% Share, According to Market Research Data",
      author: "Charles Gross",
      summary:
        "This headline-only article is meant to show you why a stock is moving, the most difficult aspect of stock trading",
      content:
        "<p>This headline-only article is meant to show you why a stock is moving, the most difficult aspect of stock trading....</p>",
      url:
        "https://www.marketwatch.com/press-release/apple-leader-in-phone-sales-in-china-for-second-straight-month-in-november-with-236-share-according-to-market-research-data-2021-12-31",
      symbols: ["AAPL"],
      creation_date: "2021-12-31T11:08:42Z",
      updated_date: "2021-12-31T11:08:43Z"
    }
  end

  def news_payload_factory do
    %{
      news: [
        %{
          id: 24_843_171,
          headline:
            "Apple Leader in Phone Sales in China for Second Straight Month in November With 23.6% Share, According to Market Research Data",
          author: "Charles Gross",
          created_at: "2021-12-31T11:08:42Z",
          updated_at: "2021-12-31T11:08:43Z",
          summary:
            "This headline-only article is meant to show you why a stock is moving, the most difficult aspect of stock trading",
          content:
            "<p>This headline-only article is meant to show you why a stock is moving, the most difficult aspect of stock trading....</p>",
          url:
            "https://www.benzinga.com/news/21/12/24843171/apple-leader-in-phone-sales-in-china-for-second-straight-month-in-november-with-23-6-share-according",
          images: [],
          symbols: [
            "AAPL"
          ],
          source: "benzinga"
        }
      ],
      next_page_token: "MTY0MDk0ODkyMzAwMDAwMDAwMHwyNDg0MzE3MQ=="
    }
  end

  def sentiment_payload_factory do
    %{
      "id" => "1234567890",
      "article_id" => "1234567890",
      "sentiment" => "positive",
      "sentiment_confidence" => 0.95,
      "sentiment_id" => 1,
      "created_at" => "2023-11-15T20:59:00Z",
      "updated_at" => "2023-11-15T20:59:00Z"
    }
  end

  def socket_factory do
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

  def ticker_factory(opts) do
    ticker = opts[:ticker] || sequence(:ticker, &"TIK#{&1}")
    user = opts[:user] || insert(:user)

    %Ticker{
      ticker: ticker,
      user_id: user.id
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
      email: sequence(:email, &"test-email#{&1}@foo.com")
    }
  end
end

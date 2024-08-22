defmodule Basket.TickerTest do
  @moduledoc false

  use Basket.DataCase, async: false

  import Basket.Factory

  alias Basket.{Repo, Ticker}

  describe "changeset/2" do
    test "valid changeset" do
      user = insert(:user)
      attrs = %{ticker: "AAPL", user_id: user.id}
      changeset = Ticker.changeset(%Ticker{}, attrs)

      assert changeset.valid?
    end

    test "invalid changeset without required fields" do
      changeset = Ticker.changeset(%Ticker{}, %{})

      refute changeset.valid?

      assert %{
               errors: [
                 ticker: {"can't be blank", [validation: :required]},
                 user_id: {"can't be blank", [validation: :required]}
               ]
             } = changeset
    end
  end

  describe "active_ticker_list/0" do
    test "returns a list of active tickers" do
      insert(:ticker, ticker: "AAPL")
      insert(:ticker, ticker: "GOOG")
      insert(:club_ticker, ticker: "MSFT")

      assert Ticker.active_ticker_list() == ["MSFT", "GOOG", "AAPL"]
    end
  end

  describe "add!/2" do
    test "adds a ticker for a user" do
      user = insert(:user)
      ticker = "AAPL"

      user_id = user.id
      assert %Ticker{ticker: ^ticker, user_id: ^user_id} = Ticker.add!(user, ticker)
      assert Repo.get_by(Ticker, ticker: ticker, user_id: user.id)
    end
  end

  describe "for_user/1" do
    test "returns tickers for a single user" do
      user = insert(:user)
      insert(:ticker, ticker: "AAPL", user: user)
      insert(:ticker, ticker: "GOOG", user: user)

      assert [%Ticker{ticker: "AAPL"}, %Ticker{ticker: "GOOG"}] = Ticker.for_user(user)
    end

    test "returns tickers for multiple users" do
      user1 = insert(:user)
      user2 = insert(:user)
      insert(:ticker, ticker: "AAPL", user: user1)
      insert(:ticker, ticker: "GOOG", user: user2)

      assert [%Ticker{ticker: "AAPL"}, %Ticker{ticker: "GOOG"}] = Ticker.for_user([user1, user2])
    end

    test "returns an empty list for nil user" do
      assert Ticker.for_user(nil) == []
    end
  end

  describe "remove/2" do
    test "removes a ticker for a user" do
      user = insert(:user)
      ticker = insert(:ticker, ticker: "AAPL", user: user)

      assert {1, _} = Ticker.remove(user, ticker.ticker)
      refute Repo.get_by(Ticker, ticker: ticker.ticker, user_id: user.id)
    end
  end
end

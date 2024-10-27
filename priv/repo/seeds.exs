# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Basket.Repo.insert!(%Basket.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Basket.Repo
alias Basket.{User, Club, Ticker, News, ClubMember, ClubTicker}

# Remove existing data
Repo.delete_all(News)
Repo.delete_all(ClubTicker)
Repo.delete_all(Ticker)
Repo.delete_all(ClubMember)
Repo.delete_all(User)
Repo.delete_all(Club)

# Create Users
user1 =
  %User{
    email: "user1@example.com",
    password_hash: Password.pbkdf2_hash("password"),
    settings: %{"theme" => "dark"}
  }
  |> Repo.insert!()

user2 =
  %User{
    email: "user2@example.com",
    password_hash: Password.pbkdf2_hash("password"),
    settings: %{"theme" => "light"}
  }
  |> Repo.insert!()

# Create Clubs
club1 =
  %Club{
    name: "Club One"
  }
  |> Repo.insert!()

club2 =
  %Club{
    name: "Club Two"
  }
  |> Repo.insert!()

# Associate Users with Clubs
Repo.insert_all("club_members", [
  %{user_id: user1.id, club_id: club1.id},
  %{user_id: user2.id, club_id: club2.id}
])

# Create Tickers
ticker1 =
  %Ticker{
    ticker: "AAPL",
    user_id: user1.id
  }
  |> Repo.insert!()

ticker2 =
  %Ticker{
    ticker: "GOOGL",
    user_id: user2.id
  }
  |> Repo.insert!()

# Create News
news1 =
  %News{
    article_id: "article_1",
    author: "Author One",
    content: "Content of the article",
    creation_date:
      DateTime.utc_now() |> DateTime.add(-86400, :second) |> DateTime.truncate(:second),
    headline: "Headline One",
    images: [%{"url" => "http://example.com/image1.jpg"}],
    sentiment: "positive",
    sentiment_confidence: Decimal.new("0.95"),
    sentiment_id: 1,
    source: "Source One",
    summary: "Summary of the article",
    symbols: ["AAPL"],
    updated_date: DateTime.utc_now() |> DateTime.truncate(:second),
    url: "http://example.com/article1"
  }
  |> Repo.insert!()

news2 =
  %News{
    article_id: "article_2",
    author: "Author Two",
    content: "Content of the article",
    creation_date:
      DateTime.utc_now() |> DateTime.add(-86400, :second) |> DateTime.truncate(:second),
    headline: "Headline Two",
    images: [%{"url" => "http://example.com/image2.jpg"}],
    sentiment: "negative",
    sentiment_confidence: Decimal.new("0.85"),
    sentiment_id: 2,
    source: "Source Two",
    summary: "Summary of the article",
    symbols: ["GOOGL"],
    updated_date: DateTime.utc_now() |> DateTime.truncate(:second),
    url: "http://example.com/article2"
  }
  |> Repo.insert!()

# Create ClubTickers
club_ticker1 =
  %ClubTicker{
    ticker: "AAPL",
    club_id: club1.id
  }
  |> Repo.insert!()

club_ticker2 =
  %ClubTicker{
    ticker: "GOOGL",
    club_id: club2.id
  }
  |> Repo.insert!()

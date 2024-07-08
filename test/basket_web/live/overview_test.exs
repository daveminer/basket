defmodule BasketWeb.Live.OverviewTest do
  @moduledoc false

  use BasketWeb.ConnCase, async: false

  import Basket.Factory
  import Mox
  import Phoenix.LiveViewTest

  alias BasketWeb.Live.Overview.TickerRow
  alias Basket.{Ticker, User}
  alias Pow.Ecto.Schema.Password

  setup :set_mox_global
  setup :verify_on_exit!

  setup do
    # hash "password" so it can be inserted into the database
    user_pass = "password"
    password_hash = Password.pbkdf2_hash(user_pass)

    # create a user
    user =
      %User{
        email: "test@example.com",
        password_hash: password_hash
      }
      |> Basket.Repo.insert!()

    # give the user a ticker
    %Ticker{
      user_id: user.id,
      ticker: "ALPHA"
    }
    |> Basket.Repo.insert!()

    # log in
    conn = Plug.Test.conn(:get, "/session/new")

    conn =
      post(
        conn,
        "/session",
        %{
          "user" => %{
            "email" => "test@example.com",
            "password" => user_pass
          }
        }
      )

    {:ok,
     %{
       bars: build(:bars_payload),
       basket_with_row: [
         %TickerRow{
           id: "XYZ",
           ticker: "XYZ",
           close: 188.15,
           high: 188.15,
           low: 188.05,
           count: 358,
           open: 188.11,
           timestamp: "2023-11-15T20:59:00Z",
           volume: 4_303_143_025,
           vwap: 188.117416
         }
       ],
       conn: conn
     }}
  end

  describe "ticker" do
    test "adds and removes bars data to the liveview for the selected ticker", %{
      conn: conn
    } do
      Basket.Http.MockAlpaca
      |> expect(:latest_quote, fn _ -> {:ok, %{"bars" => build(:bars_payload)}} end)

      Basket.Http.MockAlpaca
      |> expect(:latest_quote, fn _ ->
        {:ok, %{"bars" => build(:bars_payload, ticker: "BETA")}}
      end)

      Basket.Websocket.MockClient
      |> expect(:send_frame, 4, fn _, _ -> :ok end)

      # Overview loads with a ticker
      {:ok, view, _html} = live(conn, "/")
      assert render(view) =~ "<td data-key=\"ALPHA_ticker\""

      # Add a second ticker to the view
      send(view.pid, {"ticker-add", %{"ticker" => "BETA"}})

      assert render(view) =~ "<td data-key=\"BETA_ticker\""

      # Remove the tickers
      render_hook(view, "ticker-remove", %{"ticker" => "ALPHA"})
      render_hook(view, "ticker-remove", %{"ticker" => "BETA"})

      # Load an empty view
      {:ok, _empty_view, _html} = live(conn, "/")
      assert render(view) =~ "<input id=\"ticker-input\""
    end
  end
end

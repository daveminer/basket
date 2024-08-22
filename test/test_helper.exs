Mox.defmock(Basket.Websocket.MockClient, for: Basket.Websocket.Client)
Application.put_env(:basket, :websocket_client, Basket.Websocket.MockClient)

Mox.defmock(Basket.Http.MockAlpaca, for: Basket.Http.Alpaca)
Application.put_env(:basket, :alpaca_http_client, Basket.Http.MockAlpaca)

Mox.defmock(Basket.Http.MockSentiment, for: Basket.Http.Sentiment)
Application.put_env(:basket, :sentiment_http_client, Basket.Http.MockSentiment)

{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Basket.Repo, :manual)

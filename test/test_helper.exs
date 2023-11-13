Mox.defmock(Basket.Alpaca.Websocket.MockClient, for: Basket.Alpaca.Websocket.Client)
Application.put_env(:basket, :alpaca_websocket_client, Basket.Alpaca.Websocket.MockClient)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Basket.Repo, :manual)

Mox.defmock(Basket.Websocket.MockAlpaca, for: Basket.Websocket.Alpaca)
Application.put_env(:basket, :alpaca_ws_client, Basket.Websocket.MockAlpaca)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Basket.Repo, :manual)

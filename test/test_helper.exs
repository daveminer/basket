{:ok, _} = Application.ensure_all_started(:ex_machina)

Mox.defmock(Basket.Websocket.MockAlpaca, for: Basket.Websocket.Alpaca)
Application.put_env(:basket, :alpaca_ws_client, Basket.Websocket.MockAlpaca)

Mox.defmock(Basket.Http.MockAlpaca, for: Basket.Http.Alpaca)
Application.put_env(:basket, :alpaca_http_client, Basket.Http.MockAlpaca)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Basket.Repo, :manual)

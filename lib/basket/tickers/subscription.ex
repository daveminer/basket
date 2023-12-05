defmodule Basket.Tickers.Subscription do
  use Phoenix.Presence,
    otp_app: :basket,
    pubsub_server: Basket.PubSub
end

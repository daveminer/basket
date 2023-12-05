defmodule BasketWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :basket,
    pubsub_server: Basket.PubSub

  @doc """
  Keeps track of presence state within the process.
  """
  # def init(_opts) do
  #   {:ok, %{}}
  # end

  # @doc """
  # Add an id and user to the presence.
  # """
  # def fetch(_topic, presences) do
  #   for {key, %{metas: [meta | metas]}} <- presences, into: %{} do
  #     # user can be populated here from the database here we populate
  #     # the name for demonstration purposes
  #     {key, %{metas: [meta | metas], id: meta.id, user: %{name: meta.id}}}
  #   end
  # end

  # @doc """
  # Updates the presence state based on Ticker addition and removal.
  # """
  # def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
  #   for {user_id, presence} <- joins do
  #     user_data = %{id: user_id, user: presence.user, metas: Map.fetch!(presences, user_id)}
  #     msg = {__MODULE__, {:join, user_data}}
  #     Phoenix.PubSub.local_broadcast(Hello.PubSub, "proxy:#{topic}", msg)
  #   end

  #   for {user_id, presence} <- leaves do
  #     metas =
  #       case Map.fetch(presences, user_id) do
  #         {:ok, presence_metas} -> presence_metas
  #         :error -> []
  #       end

  #     user_data = %{id: user_id, user: presence.user, metas: metas}
  #     msg = {__MODULE__, {:leave, user_data}}
  #     Phoenix.PubSub.local_broadcast(Hello.PubSub, "proxy:#{topic}", msg)
  #   end

  #   {:ok, state}
  # end
end

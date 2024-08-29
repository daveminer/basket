defmodule Basket.Http.Sentiment do
  @moduledoc """
  Interface for the BERT-Serv Sentiment API.
  """

  defstruct [
    :id,
    :label,
    :score,
    :tags,
    :text,
    :created_at
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          label: String.t(),
          score: float(),
          tags: [String.t()],
          text: String.t(),
          created_at: String.t()
        }

  @callback get_sentiment(id :: String.t()) :: {:ok, map()} | {:error, String.t()}
  @callback run_sentiment(id :: String.t(), tags :: list(String.t()), text :: String.t()) ::
              :ok | {:error, String.t()}

  def get_sentiment(id), do: impl().get_sentiment(id)

  def run_sentiment(id, tags, text), do: impl().run_sentiment(id, tags, text)

  defp impl,
    do: Application.get_env(:basket, :sentiment_http_client, Basket.Http.Sentiment.Impl)
end

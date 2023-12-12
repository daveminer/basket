defmodule Basket.Http.Alpaca do
  @moduledoc """
  Interface for the Alpaca REST API.
  """

  defstruct x: "",
            y: false,
            z: 0

  @type bars :: %__MODULE__{
          x: String.t(),
          y: boolean,
          z: integer
        }

  @callback latest_quote(ticker :: String.t()) :: {:ok, list(map())} | {:error, String.t()}
  @callback list_assets() :: {:ok, list(map())} | {:error, String.t()}

  def latest_quote(ticker), do: impl().latest_quote(ticker)
  def list_assets, do: impl().list_assets()

  defp impl,
    do: Application.get_env(:basket, :alpaca_http_client, Basket.Http.Alpaca.Impl)
end

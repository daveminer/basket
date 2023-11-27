defmodule Basket.Support.MockWebsocketServer do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  match _ do
    send_resp(conn, 200, "Hello from plug")
  end

  def start(pid) when is_pid(pid) do
    ref = make_ref()
    port = get_port()
    {:ok, agent_pid} = Agent.start_link(fn -> :ok end)
    url = "ws://localhost:#{port}"

    opts = [dispatch: dispatch({pid, agent_pid}), port: port, ref: ref]

    case Plug.Cowboy.http(__MODULE__, [], opts) do
      {:ok, _} ->
        {:ok, {agent_pid, ref, url}}

      {:error, :eaddrinuse} ->
        start(pid)
    end
  end

  def shutdown(ref) do
    Plug.Cowboy.shutdown(ref)
  end

  def receive_socket_pid do
    receive do
      pid when is_pid(pid) -> pid
    after
      500 -> raise "No Server Socket pid"
    end
  end

  defp dispatch(tuple) do
    IO.inspect(tuple, label: "TUPLE")
    [{:_, [{"/iex", Basket.Support.TestSocket, [tuple]}]}]
  end

  defp get_port do
    unless Process.whereis(__MODULE__), do: start_ports_agent()

    Agent.get_and_update(__MODULE__, fn port -> {port, port + 1} end)
  end

  defp start_ports_agent do
    Agent.start(fn -> Enum.random(50_000..63_000) end, name: __MODULE__)
  end
end

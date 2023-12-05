defmodule Basket.Tickers.Reaper do
  use GenServer

  def init(init_arg) do
    {:ok, init_arg}
  end

  def monitor(server_name, pid, mfa) do
    GenServer.call(server_name, {:monitor, pid, mfa})
  end

  def demonitor(server_name, pid) do
    IO.inspect(server_name, label: "SN")
    IO.inspect(pid, label: "PID")
    GenServer.call(server_name, {:demonitor, pid})
  end
end

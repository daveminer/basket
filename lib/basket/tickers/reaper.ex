defmodule Basket.Tickers.Reaper do
  @moduledoc """
  Because a client LiveView process may exit before it send a disconnect message
  to the server, those processes are monitored by this one. When a client disconnects,
  the :DOWN event will be caught and processed by handle_info/2.
  """
  use GenServer

  @doc """
  Add a LiveView to the list of tracked processes.

  ## Example:
      iex> Basket.Tickers.Reaper.monitor("phx-test")
      :ok
  """
  @spec monitor(String.t()) :: {:reply, :ok, map()}
  def monitor(socket_id), do: GenServer.call(__MODULE__, {:monitor, socket_id})

  @spec demonitor :: {:reply, :ok, map()}
  def demonitor, do: GenServer.call(__MODULE__, :demonitor)

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(init_arg), do: GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)

  @spec init(any()) :: {:ok, %{views: %{}}}
  def init(_), do: {:ok, %{views: %{}}}

  @spec handle_call({:monitor, String.t()}, {pid(), reference()}, map()) :: {:reply, :ok, map()}
  def(handle_call({:monitor, socket_id}, {view_pid, _ref}, %{views: views} = state)) do
    mref = Process.monitor(view_pid)

    track()

    {:reply, :ok, %{state | views: Map.put(views, view_pid, {socket_id, mref})}}
  end

  @spec handle_call(:demonitor, {pid(), reference()}, map()) :: {:reply, :ok, map()}
  def handle_call(:demonitor, {view_pid, _ref}, state) do
    {{_socket_id, mref}, new_views} = Map.pop(state.views, view_pid, {{nil, nil}, state.views})

    if is_pid(mref) do
      untrack()
      :erlang.demonitor(mref)
    end

    {:reply, :ok, %{state | views: new_views}}
  end

  @doc """
  Called when a client disconnects or halts. Removes the user and their tickers from tracking.

  ## Example
      iex> Basket.Tickers.Reaper.handle_info({:DOWN, nil, :process, "pid", {:shutdown, :closed}}, %{views: %{"pid" => {"socket_id", make_ref()}, "other" => {"other_socket_id", make_ref()}}})
      {:noreply, %{views: %{"other" => {"other_socket_id"}}}}
  """
  @spec handle_info({:DOWN, reference(), :process, pid(), any()}, map()) :: {:noreply, map()}
  def handle_info({:DOWN, _ref, :process, view_pid, _shutdown_signal}, state) do
    {{_socket_id, _mref}, new_views} = Map.pop(state.views, view_pid, {{nil, nil}, state.views})

    # Remove user from tracking
    untrack()

    {:noreply, %{state | views: new_views}}
  end

  def track do
  end

  def untrack do
  end
end

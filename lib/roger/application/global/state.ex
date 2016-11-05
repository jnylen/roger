defmodule Roger.Application.Global.State do
  @moduledoc false
  defstruct application: nil, cancel_set: nil, queue_set: nil, execute_set: nil, paused: MapSet.new

  alias Roger.KeySet

  def serialize(struct) do
    {:ok, cancel_set} = KeySet.get_state(struct.cancel_set)
    {:ok, queue_set} = KeySet.get_state(struct.queue_set)
    {:ok, execute_set} = KeySet.get_state(struct.execute_set)
    %{
      cancel_set: cancel_set,
      queue_set: queue_set,
      execute_set: execute_set,
      paused: struct.paused
    }
    |> :erlang.term_to_binary
  end

  def deserialize(data) do
    struct = :erlang.binary_to_term(data)
    {:ok, cancel_set} = KeySet.start_link(state: struct[:cancel_set])
    {:ok, queue_set} = KeySet.start_link(state: struct[:queue_set])
    {:ok, execute_set} = KeySet.start_link(state: struct[:execute_set])
    %__MODULE__{
      cancel_set: cancel_set,
      queue_set: queue_set,
      execute_set: execute_set,
      paused: struct.paused}
  end

  def merge(a, b) do
    KeySet.union(a.cancel_set, b.cancel_set)
    KeySet.union(a.queue_set, b.queue_set)
    KeySet.union(a.execute_set, b.execute_set)
    %__MODULE__{a | paused: MapSet.union(a.paused, b.paused)}
  end
end

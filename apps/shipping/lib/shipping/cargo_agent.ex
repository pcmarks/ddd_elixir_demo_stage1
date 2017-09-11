defmodule Shipping.CargoAgent do
  @moduledoc """
  CargoAgent is an Elixir Agent that maintains a state which contains
  the Cargoes that have been booked (although there is no booking function in
  stage 1 of this demo) and also the last id that was
  assigned to the cargo before storage. This agent is supervised - see Shipping.Application

  A backing store - a file - contains all of the cargoes. It is read
  when this Agent is started (start_link()). The backing store data is stored in
  JSON format.
  """
  defp cache_file_path, do: Application.get_env(:shipping, :cargoes_cache)

  defstruct [cargoes: [], last_cargo_id: 0, cache: nil]

  # The Aggregate is Cargoes
  alias Shipping.Cargoes.Cargo

  @doc """
  Before starting the Agent process, start_link first loads any Cargoes
  that might be stored in the file cache ("cargoes.json"). Any cargoes
  become part of the Agent's state.
  """
  def start_link do
    {:ok, cache} = File.open(cache_file_path(), [:append, :read])
    {cargoes, last_cargo_id} = load_from_cache(cache, {[], 0})
    Agent.start_link(fn -> %__MODULE__{cache: cache, cargoes: cargoes, last_cargo_id: last_cargo_id} end, name: __MODULE__)
  end

  # Reset the cargo status to "BOOKING"
  defp load_from_cache(cache, {cargoes, last_cargo_id} = acc) do
    case IO.read(cache, :line) do
      :eof -> acc
      cargo ->
        cargo_struct =
          cargo
            |> String.trim_trailing("\n")
            |> Poison.decode!(as: %Cargo{})
            |> Map.put(:status, "NOT RECEIVED")
        load_from_cache(cache, {[cargo_struct | cargoes], cargo_struct.id})
    end
  end

  defp dump_to_cache() do
    cache = Agent.get(__MODULE__, fn(struct) -> struct.cache end)
    File.close(cache)
    File.rm(cache_file_path())
    {:ok, new_cache} = File.open(cache_file_path(), [:append, :read])
    all()
      |> Enum.map(
          fn(cargo) -> IO.write(new_cache, to_json(cargo) <> "\n")
          end)
    Agent.update(__MODULE__, fn(struct) -> %{struct | cache: new_cache} end)
  end

  @doc """
  Return all of the cargoes in the agents state as a list. This function
  is meant to act like a database select all.
  """
  def all() do
    Agent.get(__MODULE__, fn(struct) -> struct.cargoes end)
  end

  @doc """
  Add a cargo to the current state and append it to the cache file. This
  function is meant to behave like a database insert.
  """
  def add(%Cargo{} = cargo) do
    id = next_id()
    new_cargo = %{cargo | id: id}
    Agent.update(__MODULE__,
      fn(struct) ->
        %{struct | cargoes: [new_cargo | struct.cargoes]}
      end)
    cache = Agent.get(__MODULE__, fn(s) -> s.cache end)
    IO.write(cache, to_json(new_cargo) <> "\n")
    new_cargo
  end

  defp to_json(cargo) do
    # Remove Ecto field before encoding
    cargo |> Map.delete(:__meta__) |> Poison.encode!
  end

  @doc """
  Update an existing Cargo. Matching is done using
  the Cargo id value.
  """
  def update(%Cargo{} = updated_cargo) do
    new_cargo_list =
      all()
      |> Enum.map(
          fn(cargo) ->
            if cargo.id == updated_cargo.id do
              updated_cargo
            else
              cargo
            end
          end)
    Agent.update(__MODULE__,
        fn(struct) ->
          %{struct | cargoes: new_cargo_list}
        end)
    dump_to_cache()
    updated_cargo
  end

  def next_id() do
    Agent.get_and_update(__MODULE__,
    fn(struct) ->
      next_id = struct.last_cargo_id + 1
      {next_id, %{struct | last_cargo_id: next_id}}
    end)
  end

end

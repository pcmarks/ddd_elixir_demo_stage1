defmodule Shipping.CargoAgent do
  @moduledoc """
  CargoAgent is an Elixir Agent that maintains a state which contains
  the Cargoes that have been booked (although there is no booking function in
  stage 1 of this demo) and also the last id that was assigned to the cargo
  before storage. This Agent is supervised - see Shipping.Application

  A backing store - a file - contains all of the cargoes. It is read
  when this Agent is started (start_link()). The backing store data is stored in
  JSON format.

  NOTE: Many of the, primarly private, functions have a "test" version that
  does not use any backing store. This behavior is determined by the
  Application environment variable: :shipping, :env that contains the value of
  Mix.env()
  """
  @app_dir File.cwd!()
  @project_root_dir Path.join([@app_dir, "..", ".."])
  @cache_file_path Path.join([@project_root_dir, "resources", "cargoes.json"])

  defstruct [cargoes: [], last_cargo_id: 0, cache: nil]

  # The Aggregate is Cargoes
  alias Shipping.Cargoes.Cargo

  @doc """
  Before starting the Agent process, start_link first loads any Cargoes
  that might be stored in the file cache ("cargoes.json"). Any cargoes
  become part of the Agent's state.
  """
  def start_link do
    # cache will be nil if we are testing
    {:ok, cache} = open_cache(Application.get_env(:shipping, :env))
    {cargoes, last_cargo_id} = load_from_cache(cache, {[], 0})
    Agent.start_link(fn -> %__MODULE__{cache: cache, cargoes: cargoes, last_cargo_id: last_cargo_id} end, name: __MODULE__)
  end

  defp open_cache(:test), do: {:ok, nil}
  defp open_cache(_) do
    {:ok, cache} = File.open(@cache_file_path, [:append, :read])
  end

  defp load_from_cache(nil, _state), do: {[], 0}
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

  defp dump_to_cache(nil), do: nil
  defp dump_to_cache(cache) do
    File.close(cache)
    File.rm(@cache_file_path)
    {:ok, new_cache} = File.open(@cache_file_path, [:append, :read])
    all()
      |> Enum.map(
          fn(cargo) -> IO.write(new_cache, to_json(cargo) <> "\n")
          end)
    Agent.update(__MODULE__, fn(struct) -> %{struct | cache: new_cache} end)
  end

  @doc """
  Return all of the cargoes in the Agent's state as a list. This function
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
    write_to_cache(cache, new_cargo)
    new_cargo
  end

  defp write_to_cache(nil, _new_cargo), do: nil
  defp write_to_cache(cache, new_cargo) do
    IO.write(cache, to_json(new_cargo) <> "\n")
  end

  defp to_json(cargo) do
    # Remove Ecto field before encoding
    cargo |> Map.delete(:__meta__) |> Poison.encode!
  end

  @doc """
  Update an existing Cargo. Matching is done using the Cargo id value.
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
    cache = Agent.get(__MODULE__, fn(struct) -> struct.cache end)
    dump_to_cache(cache)
    updated_cargo
  end

  defp next_id() do
    Agent.get_and_update(__MODULE__,
    fn(struct) ->
      next_id = struct.last_cargo_id + 1
      {next_id, %{struct | last_cargo_id: next_id}}
    end)
  end

end

defmodule Shipping.HandlingEventAgent do
  @moduledoc """
  HandlingEventAgent is an Agent that maintains a state which contains
  the HandlingEvents that have arrived and also the last id that was
  assigned to the event before storage. This Agent is supervised - see Shipping.Application

  A backing store - a file - contains all events past and present. It is read
  when this Agent is started (start_link) and is written to (appended) when a
  new handling event is inserted. The backing store data is stored in
  JSON format.
  """
  @handling_event_file "handling_events.json"

  defstruct [events: [], last_event_id: 0, cache: nil, cache_path: ""]

  # The aggregate is HandlingEvents
  alias Shipping.HandlingEvents.HandlingEvent

  alias Shipping.Application

  @doc """
  Before starting the Agent process, start_link first loads any Handling Events
  that might be stored in the file cache ("handling_events.json"). Any events
  become part of the Agent's state.
  """
  def start_link do
    cache_path = Application.prepare_cache(@handling_event_file)
    {:ok, cache} = File.open(cache_path, [:append, :read])
    {events, last_event_id} = load_from_cache(cache, {[], 0})
    Agent.start_link(fn ->
      %__MODULE__{cache: cache,
                  events: events,
                  last_event_id: last_event_id,
                  cache_path: cache_path}
      end,
      name: __MODULE__)
  end

  defp load_from_cache(cache, {events, _last_event_id} = acc) do
    case IO.read(cache, :line) do
      :eof -> acc
      event ->
        event_struct =
          event
            |> String.trim_trailing("\n")
            |> Poison.decode!(as: %HandlingEvent{})
            |> convert_date(:completion_time)
            |> convert_date(:registration_time)
        load_from_cache(cache, {[event_struct | events], event_struct.id})
    end
  end

  defp convert_date(event, field) do
    {:ok, converted_date, _} = DateTime.from_iso8601(Map.get(event, field))
    Map.put(event, field, converted_date)
  end

  defp dump_to_cache() do
    {cache, cache_path} = Agent.get(__MODULE__,
                                    fn(struct) -> {struct.cache, struct.cache_path} end)
    File.close(cache)
    File.rm(cache_path)
    {:ok, new_cache} = File.open(cache_path, [:append, :read])
    all()
      |> Enum.map(
          fn(event) -> IO.write(new_cache, to_json(event) <> "\n")
          end)
    Agent.update(__MODULE__, fn(struct) -> %{struct | cache: new_cache} end)
  end

  @doc """
  Return all of the Handling Events in the Agent's state as a list. This function
  is meant to act like a database select all.
  """
  def all() do
    Agent.get(__MODULE__, fn(struct) -> struct.events end)
  end

  @doc """
  Add a handling event to the current state and append it to the cache file. This
  function is meant to behave like a database insert.
  """
  def add(%HandlingEvent{} = event) do
    id = next_id()
    new_event = %{event | id: id}
    Agent.update(__MODULE__,
      fn(struct) ->
        %{struct | events: [new_event | struct.events]}
      end)
    cache = Agent.get(__MODULE__, fn(s) -> s.cache end)
    IO.write(cache, to_json(new_event) <> "\n")
    new_event
  end

  defp to_json(event) do
    # Remove Ecto field before encoding
    event |> Map.delete(:__meta__) |> Poison.encode!
  end

  @doc """
  Update an existing Handling Event. Matching is done using
  the Handling Event id value.
  """
  def update(%HandlingEvent{} = updated_event) do
    new_event_list =
      all()
      |> Enum.map(
          fn(event) ->
            if event.id == updated_event.id do
              updated_event
            else
              event
            end
          end)
    Agent.update(__MODULE__,
        fn(struct) ->
          %{struct | events: new_event_list}
        end)
    dump_to_cache()
    updated_event
  end

  def next_id() do
    Agent.get_and_update(__MODULE__,
    fn(struct) ->
      next_id = struct.last_event_id + 1
      {next_id, %{struct | last_event_id: next_id}}
    end)
  end

end

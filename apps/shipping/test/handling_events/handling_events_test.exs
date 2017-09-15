defmodule Shipping.HandlingEventsTest do
  use ExUnit.Case

  alias Shipping.Cargoes.Cargo
  alias Shipping.CargoAgent
  alias Shipping.HandlingEventAgent
  alias Shipping.HandlingEvents
  alias Shipping.HandlingEvents.HandlingEvent

  @test_handling_events [
    %{voyage: "", type: "RECEIVE", tracking_id: "ABC123", registration_time: "2017-07-06T21:15:20.591000Z", location: "USNYC", completion_time: "2017-06-09T00:00:00Z"},
    %{voyage: "", type: "CUSTOMS", tracking_id: "ABC123", registration_time: "2017-07-14T20:42:29.716000Z", location: "USNYC", completion_time: "2017-06-10T00:00:00Z"},
    %{voyage: "989", type: "LOAD", tracking_id: "ABC123", registration_time: "2017-07-15T15:10:15.903000Z", location: "USNYC", completion_time: "2017-06-12T00:00:00Z"}
  ]

  @test_cargoes [
    %{tracking_id: "ABC123", status: "NOT RECEIVED"},
    %{tracking_id: "IJK456", status: "NOT RECEIVED"}
  ]

  setup_all do
    for cargo_attrs <- @test_cargoes do
      changeset = Cargo.changeset(%Cargo{}, cargo_attrs)
      if changeset.valid? do
        data = Ecto.Changeset.apply_changes(changeset)
        CargoAgent.add(data)
      end
    end
    for handling_event_attrs <-@test_handling_events do
      changeset = HandlingEvent.changeset(%HandlingEvent{}, handling_event_attrs)
      if changeset.valid? do
        data = Ecto.Changeset.apply_changes(changeset)
        HandlingEventAgent.add(data)
      end
    end
    :ok
  end

  # NOTE: These test assume that there are 3 handling events in the resource.

  test "List all handling events" do
    handling_events = HandlingEvents.list_handling_events
    assert length(handling_events) >= 3
  end

  test "Get handling events by tracking id" do
    handling_events = HandlingEvents.get_handling_events_by_tracking_id!("ABC123")
    assert length(handling_events) >= 3
  end

  test "Get handling events for non-existent tracking id" do
    handling_events = HandlingEvents.get_handling_events_by_tracking_id!("FOO")
    assert length(handling_events) >= 0
  end

  test "Get a handling event by its ID as a string" do
    handling_event = HandlingEvents.get_handling_event!("1")
    assert handling_event.id == 1
  end

  test "Get a handling event by its ID as an integer" do
    handling_event = HandlingEvents.get_handling_event!(1)
    assert handling_event.id == 1
  end

  test "Create a handling event" do
    {result, handling_event} = HandlingEvents.create_handling_event(
      %{type: "UNLOAD", location: "CHI" , completion_time: DateTime.utc_now, tracking_id: "ABC123", voyage: "989"})
    assert result == :ok
    assert handling_event.location == "CHI"
  end

  test "Fail to create a handling event" do
    # Missing type value
    result = HandlingEvents.create_handling_event(
      %{type: "", location: "CHI" , completion_time: DateTime.utc_now, tracking_id: "ABC123", voyage: "989"})
    assert match?({:error, _}, result)
  end

end

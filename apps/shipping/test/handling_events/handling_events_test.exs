defmodule Shipping.HandlingEventsTest do
  use ExUnit.Case

  alias Shipping.HandlingEvents

  # Testing data is created in test_helper.exs
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

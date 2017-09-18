ExUnit.start()

alias Shipping.Cargoes.Cargo
alias Shipping.CargoAgent
alias Shipping.HandlingEventAgent
alias Shipping.HandlingEvents.HandlingEvent

test_handling_events =
  [
  %{voyage: "", type: "RECEIVE", tracking_id: "ABC123", registration_time: "2017-07-06T21:15:20.591000Z", location: "USNYC", completion_time: "2017-06-09T00:00:00Z"},
  %{voyage: "", type: "CUSTOMS", tracking_id: "ABC123", registration_time: "2017-07-14T20:42:29.716000Z", location: "USNYC", completion_time: "2017-06-10T00:00:00Z"},
  %{voyage: "989", type: "LOAD", tracking_id: "ABC123", registration_time: "2017-07-15T15:10:15.903000Z", location: "USNYC", completion_time: "2017-06-12T00:00:00Z"}
  ]

test_cargoes =
  [
  %{tracking_id: "ABC123", status: "NOT RECEIVED"},
  %{tracking_id: "IJK456", status: "NOT RECEIVED"}
  ]

for cargo_attrs <- test_cargoes do
  changeset = Cargo.changeset(%Cargo{}, cargo_attrs)
  if changeset.valid? do
    data = Ecto.Changeset.apply_changes(changeset)
    CargoAgent.add(data)
  end
end
for handling_event_attrs <- test_handling_events do
  changeset = HandlingEvent.changeset(%HandlingEvent{}, handling_event_attrs)
  if changeset.valid? do
    data = Ecto.Changeset.apply_changes(changeset)
    HandlingEventAgent.add(data)
  end
end

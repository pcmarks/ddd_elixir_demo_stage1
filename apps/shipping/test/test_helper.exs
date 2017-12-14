ExUnit.start()

alias Shipping.Cargoes.Cargo
alias Shipping.CargoAgent
alias Shipping.HandlingEventAgent
alias Shipping.HandlingEvents.HandlingEvent

test_handling_events =
  [
    %{voyage: "",updated_at: nil,type: "RECEIVE",tracking_id: "ABC123",registration_time: "2017-06-10T21:15:20.591000Z",location: "USNYC",inserted_at: nil,id:  1,completion_time:  "2017-06-09T23:10:00Z"},
    %{voyage: "989",updated_at: nil,type: "LOAD",tracking_id: "ABC123",registration_time: "2017-07-12T15:13:21.903000Z",location: "USNYC",inserted_at: nil,id:  2,completion_time:  "2017-07-12T13:17:00Z"},
    %{voyage: "",updated_at: nil,type: "RECEIVE",tracking_id: "IJK456",registration_time: "2017-07-13T21:15:20.591000Z",location: "SESTO",inserted_at: nil,id:  3,completion_time:  "2017-07-12T23:10:00Z"},
    %{voyage: "989",updated_at: nil,type: "UNLOAD",tracking_id: "ABC123",registration_time: "2017-07-23T15:10:15.903000Z",location: "SESTO",inserted_at: nil,id:  4,completion_time:  "2017-07-22T08:00:00Z"},
    %{voyage: "45",updated_at: nil,type: "LOAD",tracking_id: "IJK456",registration_time: "2017-07-22T15:13:21.903000Z",location: "SESTO",inserted_at: nil,id:  5,completion_time:  "2017-07-22T13:17:00Z"},
    %{voyage: "",updated_at: nil,type: "CUSTOMS",tracking_id: "ABC123",registration_time: "2017-07-23T20:42:29.716000Z",location: "SESTO",inserted_at: nil,id:  6,completion_time:  "2017-07-23T18:37:00Z"},
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

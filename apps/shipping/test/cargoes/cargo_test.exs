defmodule Shipping.Cargoes.CargoTest do
  use ExUnit.Case

  alias Shipping.Cargoes
  alias Shipping.Cargoes.Cargo

  @valid_attrs %{status: "OK", tracking_id: "LMN123"}

  test "Cargo changeset with valid attributes" do
    changeset = Cargo.changeset(%Cargo{}, @valid_attrs)
    assert changeset.valid?
  end

  test "Cargo changeset with invalid (no) attributes" do
    changeset = Cargo.changeset(%Cargo{}, %{})
    refute changeset.valid?
  end

  test "Cargo changeset with invalid (missing) attributes" do
    changeset = Cargo.changeset(%Cargo{}, %{status: "OK"})
    refute changeset.valid?
  end

  test "Fetch some existing Delivery History" do
    history = Cargoes.get_delivery_history_for_tracking_id("ABC123")
    assert length(history) == 3
  end

end

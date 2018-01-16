defmodule Shipping.Cargoes.Cargo do
  @moduledoc """
  The root* of the Cargoes AGGREGATE*.

  From the DDD book: [An AGGREGATE is] a cluster of associated objects that
  are treated as a unit for the purgpose of data changes. External references are
  restricted to one member of the AGGREGATE, designated as the root.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Shipping.Cargoes.Cargo

  @derive {Phoenix.Param, key: :tracking_id}
  schema "cargoes" do
    field :tracking_id, :string
    timestamps()
  end

  @doc false
  def changeset(%Cargo{} = cargo, attrs) do
    cargo
    |> cast(attrs, [:tracking_id])
    |> validate_required([:tracking_id])
  end
end

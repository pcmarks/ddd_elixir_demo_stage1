defmodule Shipping.Cargoes.Cargo do
  use Ecto.Schema
  import Ecto.Changeset
  alias Shipping.Cargoes.Cargo

  @derive {Phoenix.Param, key: :tracking_id}
  schema "cargoes" do
    field :status, :string
    field :tracking_id, :string

    timestamps()
  end

  @doc false
  def changeset(%Cargo{} = cargo, attrs) do
    cargo
    |> cast(attrs, [:tracking_id, :status])
    |> validate_required([:tracking_id, :status])
  end
end

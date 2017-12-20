defmodule Shipping.Cargoes do
  @moduledoc """
  The boundary for the Cargoes Aggregate.
  """

  import Ecto.Query, warn: false
  alias Shipping.Repo

  alias Shipping.Cargoes.{Cargo, DeliveryHistory}

  @doc """
  Gets a cargo by its tracking id.

  Raises `Ecto.NoResultsError` if the Cargo does not exist.

  ## Examples

      iex> get_cargo_by_tracking_id!(123)
      %Cargo{}

      iex> get_cargo_by_tracking_id!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cargo_by_tracking_id!(tracking_id), do: Repo.get_by_tracking_id!(Cargo, tracking_id)

  @doc """
  Updates a cargo.

  ## Examples

      iex> update_cargo(cargo, %{field: new_value})
      {:ok, %Cargo{}}

      iex> update_cargo(cargo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cargo(%Cargo{} = cargo, attrs) do
    cargo
    |> Cargo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cargo changes.

  ## Examples

      iex> change_cargo(cargo)
      %Ecto.Changeset{source: %Cargo{}}

  """
  def change_cargo(%Cargo{} = cargo) do
    Cargo.changeset(cargo, %{})
  end

  @doc """
  Gets the delivery history (all handling events to date) for a tracking id. And
  then sorts it in descending order based on the completion date/time.

  Raises `Ecto.NoResultsError` if the Handling event does not exist.

  ## Examples

  """
  def get_delivery_history_for_tracking_id(tracking_id) do
    DeliveryHistory.for_tracking_id(tracking_id)
    |> Enum.sort(&(&1.completion_time >= &2.completion_time))
  end


end

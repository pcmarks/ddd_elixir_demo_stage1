defmodule Shipping.HandlingEvents do
  @moduledoc """
  The Handling Events Aggregate*. Its root is the module Shipping.HandlingEvent

  From the DDD book: [An AGGREGATE is] a cluster of associated objects that
  are treated as a unit for the purgpose of data changes. External references are
  restricted to one member of the AGGREGATE, designated as the root.
"""

  import Ecto.Query, warn: false
  alias Shipping.Repo

  alias Shipping.HandlingEvents.HandlingEvent

  @doc """
  Returns the list of all handling_events.

  ## Examples

      iex> list_handling_events()
      [%HandlingEvent{}, ...]

  """
  def list_handling_events do
    Repo.all(HandlingEvent)
  end

  @doc """
  Gets all handling events for a tracking id and returns them in
  completion_time order with the newest first.

  Raises `Ecto.NoResultsError` if the Handling event does not exist.

  ## Examples

      iex> get_handling_event_by_tracking_id!(123)
      [%HandlingEvent{}]

      iex> get_handling_event_by_tracking_id!(456)
      []

  """
  def get_all_with_tracking_id!(tracking_id) do
    Repo.get_by_tracking_id!(HandlingEvent, tracking_id)
    |> Enum.sort(&(&1.completion_time >= &2.completion_time))
  end

  @doc """
  Gets a single handling_event.

  Raises `Ecto.NoResultsError` if the Handling event does not exist.

  ## Examples

      iex> get_handling_event!(123)
      %HandlingEvent{}

      iex> get_handling_event!(456)
      []

  """
  def get_handling_event!(id), do: Repo.get!(HandlingEvent, id)

  @doc """
  Creates a handling_event.

  ## Examples

      iex> create_handling_event(%{field: value})
      {:ok, %HandlingEvent{}}

      iex> create_handling_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_handling_event(attrs \\ %{}) do
    HandlingEvent.new()
    |> HandlingEvent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking handling_event changes.

  ## Examples

      iex> change_handling_event(handling_event)
      %Ecto.Changeset{source: %HandlingEvent{}}

  """
  def change_handling_event(%HandlingEvent{} = handling_event) do
    HandlingEvent.changeset(handling_event, %{})
  end

end

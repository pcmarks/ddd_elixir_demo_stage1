defmodule Shipping.HandlingEvents do
  @moduledoc """
  The boundary for the Tracking system.
  """

  import Ecto.Query, warn: false
  alias Shipping.Repo

  alias Shipping.HandlingEvents.HandlingEvent

  @doc """
  Returns the list of handling_events.

  ## Examples

      iex> list_handling_events()
      [%HandlingEvent{}, ...]

  """
  def list_handling_events do
    Repo.all(HandlingEvent)
  end

  @doc """
  Gets all handling events for a tracking id.

  Raises `Ecto.NoResultsError` if the Handling event does not exist.

  ## Examples

      iex> get_handling_event_by_tracking_id!(123)
      [%HandlingEvent{}]

      iex> get_handling_event_by_tracking_id!(456)
      []

  """
  def get_handling_events_by_tracking_id!(tracking_id) do
    Repo.get_by_tracking_id!(HandlingEvent, tracking_id)
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

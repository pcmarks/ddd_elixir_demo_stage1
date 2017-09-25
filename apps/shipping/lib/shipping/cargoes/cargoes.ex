defmodule Shipping.Cargoes do
  @moduledoc """
  The boundary for the Cargoes Aggregate.
  """

  import Ecto.Query, warn: false
  alias Shipping.Repo

  alias Shipping.Cargoes.{Cargo, DeliveryHistory}
  alias Shipping.HandlingEvents.HandlingEvent

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

  @doc """
  Based on a cargo's current status and a list of handling events a new
  cargo status is determined, the cargo is updated with this status and a
  tuple containing the tracking status and the updated cargo is returned.
  The tracking status is either :on_track or :off_track. Note that tracking
  status is not currently used anywhere in the Stage 1 demo.
  """
  def update_cargo_status(handling_events) when is_list(handling_events) do
    cargo = get_cargo_by_tracking_id!(List.first(handling_events).tracking_id)
    do_update_cargo_status(handling_events, :on_track, cargo)
  end
  def update_cargo_status(handling_event) do
    cargo = get_cargo_by_tracking_id!(handling_event.tracking_id)
    do_update_cargo_status([handling_event], :on_track, cargo)
  end

  defp do_update_cargo_status([%HandlingEvent{type: type} | handling_events],
                          _tracking_status,
                          %Cargo{status: status} = cargo) do
    {next_tracking_status, next_status} = next_status(type, status)
    # IO.puts("STATUS: #{status} TYPE: #{type} NEXT: #{next_status}")
    do_update_cargo_status(handling_events, next_tracking_status, %{cargo | :status => next_status})
  end
  defp do_update_cargo_status([], tracking_status, cargo) do
    # Update the cargo with this final status
    case update_cargo(cargo, %{}) do
      {:ok, cargo} -> {tracking_status, cargo}
      {:error, cargo} -> {:error, cargo}
      _ -> {:error, cargo}
    end
    {tracking_status, cargo}
  end

  # State transistion for cargo status given a handling event
  # This is incomplete.
  defp next_status("RECEIVE", "NOT RECEIVED"), do: {:on_track, "IN PORT"}
  defp next_status("CUSTOMS", "IN PORT"), do: {:on_track, "IN PORT"}
  defp next_status("CLAIM", "IN PORT"), do: {:on_track, "CLAIMED"}
  defp next_status("LOAD", "CLEARED"), do: {:on_track, "ON CARRIER"}
  defp next_status("LOAD", "RECEIVED"), do: {:on_track, "ON CARRIER"}
  defp next_status("LOAD", "IN PORT"), do: {:on_track, "ON CARRIER"}
  defp next_status("LOAD", "ON CARRIER"), do: {:off_track, "ON CARRIER"}
  defp next_status("UNLOAD", "ON CARRIER"), do: {:on_track, "IN PORT"}
  defp next_status("UNLOAD", "IN PORT"), do: {:off_track, "IN PORT"}
  defp next_status(_, status), do: {:off_track, status}

  #############################################################################
  # Support for HandlingEvent types
  #############################################################################
  @handling_event_type_map %{
    "Load": "LOAD",
    "Unload": "UNLOAD",
    "Receive": "RECEIVE",
    "Claim": "CLAIM",
    "Customs": "CUSTOMS"
  }

  def handling_event_type_map do
    @handling_event_type_map
  end

end

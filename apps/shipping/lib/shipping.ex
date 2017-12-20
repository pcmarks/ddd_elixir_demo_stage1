defmodule Shipping do
  @moduledoc """
  Shipping keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Shipping.Cargoes
  alias Shipping.Cargoes.Cargo
  alias Shipping.HandlingEvents.HandlingEvent

  #############################################################################
  # Support for HandlingEvent types - Useful for UI selects
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

  @doc """
  Based on a cargo's current status and a list of handling events a new
  cargo status is determined, the cargo is updated with this status and a
  tuple containing the tracking status and the updated cargo is returned.
  The tracking status is either :on_track or :off_track. Note that tracking
  status is not currently used anywhere in the Stage 1 demo.
  """
  def update_cargo_status(handling_events, cargo) when is_list(handling_events) do
    do_update_cargo_status(handling_events, :on_track, cargo)
  end
  def update_cargo_status(handling_event, cargo) do
    do_update_cargo_status([handling_event], :on_track, cargo)
  end

  defp do_update_cargo_status([%HandlingEvent{type: type} | handling_events],
                          _tracking_status,
                          %Cargo{status: status} = cargo) do
    {next_tracking_status, next_status} = next_status(type, status)
    do_update_cargo_status(handling_events, next_tracking_status, %{cargo | :status => next_status})
  end
  defp do_update_cargo_status([], tracking_status, cargo) do
    # Update the cargo with this final status
    case Cargoes.update_cargo(cargo, %{}) do
      {:ok, cargo} -> {tracking_status, cargo}
      {:error, cargo} -> {:error, cargo}
      _ -> {:error, cargo}
    end
    {tracking_status, cargo}
  end

  # State transistions to determine a cargo's status based on its current status
  # and a handling event. In addition, there are combinations that result in
  # a tracking status (different than the cargo status) being set: :on_track or
  # :off_track.
  # This is an incomplete set of combinations.
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


end

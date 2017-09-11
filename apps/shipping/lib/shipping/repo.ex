defmodule Shipping.Repo do
  # use Ecto.Repo, otp_app: :shipping
  #
  # @doc """
  # Dynamically loads the repository url from the
  # DATABASE_URL environment variable.
  # """
  # def init(_, opts) do
  #   {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  # end
  @moduledoc """
  Normally the Repo module is responsible for the data storage and retrieval to
  and from a database system. See the commented out code above.
  However, Stage 1 of the Shipping example does not
  use a database. Instead, data is handled by Elixir Agents:
  Shipping.HandlingEventAgent and Shipping.CargoAgent. These agents maintain
  a list of HandlingEvents and Cargoes in memory (the agent's state)
  and in a file. See the agents for more detail.

  """
  alias Shipping.Cargoes.{Cargo, DeliveryHistory}
  alias Shipping.HandlingEvents.HandlingEvent
  alias Shipping.{HandlingEventAgent, CargoAgent}

  @doc """
  Retrieve all of the Cargoes from the Cargo Agent.
  """
  def all(Cargo) do
    CargoAgent.all()
  end

  @doc """
  Retrieve all of the Handling Events from the Handling Event Agent.
  """
  def all(HandlingEvent) do
    HandlingEventAgent.all()
  end

  @doc """
  Use the Handling Event Agent to insert a new Handling Event.
  """
  def insert(changeset) do
    if changeset.valid? do
      data = Ecto.Changeset.apply_changes(changeset)
      {:ok, HandlingEventAgent.add(data)}
    else
      {:error, %{changeset | action: :insert}}
    end
  end

  def get!(HandlingEvent, id) when is_binary(id) do
    get!(HandlingEvent, String.to_integer(id))
  end

  def get!(HandlingEvent, id) do
    all(HandlingEvent)
    |> Enum.find(fn handling_event -> handling_event.id == id end)
  end

  def get!(Cargo, id) when is_binary(id) do
    get!(Cargo, String.to_integer(id))
  end
  def get!(Cargo, id) do
    all(Cargo)
    |> Enum.find(fn cargo -> cargo.id == id end)
  end

  def get_by_tracking_id!(HandlingEvent, tracking_id) do
    all(HandlingEvent)
    |> Enum.filter(fn handling_event -> handling_event.tracking_id == tracking_id end)
  end

  def get_by_tracking_id!(Cargo, tracking_id) do
    all(Cargo)
    |> Enum.find(fn cargo -> cargo.tracking_id == tracking_id end)
  end

  @doc """
  Update a Handling Event using the Handling Event Agent.
  """
  def update(%{data: %HandlingEvent{}} = changeset) do
    if changeset.valid? do
      handling_event = Ecto.Changeset.apply_changes(changeset)
      {:ok, HandlingEventAgent.update(handling_event)}
    else
      {:error, %{changeset | action: :update}}
    end
  end

  @doc """
  Update a Cargo entity.
  """
  def update(%{data: %Cargo{}} = changeset) do
    if changeset.valid? do
      cargo = Ecto.Changeset.apply_changes(changeset)
      {:ok, CargoAgent.update(cargo)}
    else
      {:error, %{changeset | action: :update}}
    end
  end
end

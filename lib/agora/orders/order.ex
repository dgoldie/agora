defmodule Agora.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(pending paid cancelled)

  schema "orders" do
    field :status, :string, default: "pending"
    field :stripe_session_id, :string
    field :amount_cents, :integer

    belongs_to :listing, Agora.Catalog.Listing
    belongs_to :buyer, Agora.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:status, :stripe_session_id, :amount_cents, :listing_id, :buyer_id])
    |> validate_required([:amount_cents, :listing_id, :buyer_id])
    |> validate_inclusion(:status, @statuses)
    |> assoc_constraint(:listing)
    |> assoc_constraint(:buyer)
  end
end

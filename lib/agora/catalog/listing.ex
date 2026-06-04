defmodule Agora.Catalog.Listing do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(draft active sold)

  schema "listings" do
    field :title, :string
    field :description, :string
    field :price_cents, :integer
    field :status, :string, default: "draft"

    belongs_to :category, Agora.Catalog.Category
    belongs_to :seller, Agora.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(listing, attrs) do
    listing
    |> cast(attrs, [:title, :description, :price_cents, :status, :category_id, :seller_id])
    |> validate_required([:title, :price_cents, :category_id, :seller_id])
    |> validate_length(:title, min: 3, max: 200)
    |> validate_number(:price_cents, greater_than: 0)
    |> validate_inclusion(:status, @statuses)
    |> assoc_constraint(:category)
    |> assoc_constraint(:seller)
  end
end

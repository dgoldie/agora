defmodule Agora.Reviews.Review do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reviews" do
    field :rating, :integer
    field :body, :string

    belongs_to :listing, Agora.Catalog.Listing
    belongs_to :reviewer, Agora.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(review, attrs) do
    review
    |> cast(attrs, [:rating, :body, :listing_id, :reviewer_id])
    |> validate_required([:rating, :listing_id, :reviewer_id])
    |> validate_inclusion(:rating, 1..5)
    |> validate_length(:body, max: 1000)
    |> assoc_constraint(:listing)
    |> assoc_constraint(:reviewer)
    |> unique_constraint([:listing_id, :reviewer_id], message: "you have already reviewed this listing")
  end
end

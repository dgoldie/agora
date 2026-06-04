defmodule Agora.Reviews do
  import Ecto.Query, warn: false
  alias Agora.Repo
  alias Agora.Reviews.Review
  alias Agora.Accounts.Scope

  def list_reviews_for_listing(listing_id) do
    Repo.all(
      from r in Review,
        where: r.listing_id == ^listing_id,
        order_by: [desc: r.inserted_at],
        preload: [:reviewer]
    )
  end

  def get_review_by_reviewer(listing_id, reviewer_id) do
    Repo.get_by(Review, listing_id: listing_id, reviewer_id: reviewer_id)
  end

  def create_review(%Scope{} = scope, listing_id, attrs) do
    %Review{reviewer_id: scope.user.id, listing_id: listing_id}
    |> Review.changeset(attrs)
    |> Repo.insert()
  end

  def change_review(review \\ %Review{}, attrs \\ %{}) do
    Review.changeset(review, attrs)
  end

  def average_rating(listing_id) do
    Repo.one(
      from r in Review,
        where: r.listing_id == ^listing_id,
        select: avg(r.rating)
    )
  end
end

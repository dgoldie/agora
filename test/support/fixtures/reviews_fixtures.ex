defmodule Agora.ReviewsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Agora.Reviews` context.
  """

  @doc """
  Generate a review.
  """
  def review_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        body: "some body",
        rating: 42
      })

    {:ok, review} = Agora.Reviews.create_review(scope, attrs)
    review
  end
end

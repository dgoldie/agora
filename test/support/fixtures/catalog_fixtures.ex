defmodule Agora.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Agora.Catalog` context.
  """

  @doc """
  Generate a unique category slug.
  """
  def unique_category_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a category.
  """
  def category_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        icon: "some icon",
        name: "some name",
        slug: unique_category_slug()
      })

    {:ok, category} = Agora.Catalog.create_category(scope, attrs)
    category
  end

  @doc """
  Generate a listing.
  """
  def listing_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        price_cents: 42,
        status: "some status",
        title: "some title"
      })

    {:ok, listing} = Agora.Catalog.create_listing(scope, attrs)
    listing
  end
end

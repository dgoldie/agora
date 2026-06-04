defmodule Agora.Catalog do
  @moduledoc """
  The Catalog context — categories and listings.
  """

  import Ecto.Query, warn: false
  alias Agora.Repo
  alias Agora.Catalog.{Category, Listing}
  alias Agora.Accounts.Scope

  # ---------------------------------------------------------------------------
  # Categories (global — no user scope)
  # ---------------------------------------------------------------------------

  def list_categories do
    Repo.all(from c in Category, order_by: c.name)
  end

  def get_category!(id), do: Repo.get!(Category, id)

  def create_category(attrs) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = category), do: Repo.delete(category)

  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  # ---------------------------------------------------------------------------
  # Listings
  # ---------------------------------------------------------------------------

  def list_listings(filters \\ []) do
    Listing
    |> filter_by_category(filters[:category_id])
    |> filter_by_status(filters[:status] || "active")
    |> filter_by_search(filters[:search])
    |> order_by([l], desc: l.inserted_at)
    |> preload([:category, :seller])
    |> Repo.all()
  end

  def list_listings_for_seller(%Scope{} = scope) do
    Repo.all(
      from l in Listing,
        where: l.seller_id == ^scope.user.id,
        order_by: [desc: l.inserted_at],
        preload: [:category]
    )
  end

  def get_listing!(id) do
    Listing
    |> preload([:category, :seller])
    |> Repo.get!(id)
  end

  def create_listing(%Scope{} = scope, attrs) do
    %Listing{seller_id: scope.user.id}
    |> Listing.changeset(attrs)
    |> Repo.insert()
  end

  def update_listing(%Scope{} = scope, %Listing{} = listing, attrs) do
    true = listing.seller_id == scope.user.id

    listing
    |> Listing.changeset(attrs)
    |> Repo.update()
  end

  def delete_listing(%Scope{} = scope, %Listing{} = listing) do
    true = listing.seller_id == scope.user.id
    Repo.delete(listing)
  end

  def change_listing(%Listing{} = listing, attrs \\ %{}) do
    Listing.changeset(listing, attrs)
  end

  # ---------------------------------------------------------------------------
  # Private query helpers
  # ---------------------------------------------------------------------------

  defp filter_by_category(query, nil), do: query
  defp filter_by_category(query, id), do: where(query, [l], l.category_id == ^id)

  defp filter_by_status(query, nil), do: query
  defp filter_by_status(query, status), do: where(query, [l], l.status == ^status)

  defp filter_by_search(query, nil), do: query
  defp filter_by_search(query, ""), do: query

  defp filter_by_search(query, term) do
    pattern = "%#{term}%"
    where(query, [l], ilike(l.title, ^pattern) or ilike(l.description, ^pattern))
  end
end

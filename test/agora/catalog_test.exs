defmodule Agora.CatalogTest do
  use Agora.DataCase

  alias Agora.Catalog

  describe "categories" do
    alias Agora.Catalog.Category

    import Agora.AccountsFixtures, only: [user_scope_fixture: 0]
    import Agora.CatalogFixtures

    @invalid_attrs %{name: nil, slug: nil, icon: nil}

    test "list_categories/1 returns all scoped categories" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      category = category_fixture(scope)
      other_category = category_fixture(other_scope)
      assert Catalog.list_categories(scope) == [category]
      assert Catalog.list_categories(other_scope) == [other_category]
    end

    test "get_category!/2 returns the category with given id" do
      scope = user_scope_fixture()
      category = category_fixture(scope)
      other_scope = user_scope_fixture()
      assert Catalog.get_category!(scope, category.id) == category
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_category!(other_scope, category.id) end
    end

    test "create_category/2 with valid data creates a category" do
      valid_attrs = %{name: "some name", slug: "some slug", icon: "some icon"}
      scope = user_scope_fixture()

      assert {:ok, %Category{} = category} = Catalog.create_category(scope, valid_attrs)
      assert category.name == "some name"
      assert category.slug == "some slug"
      assert category.icon == "some icon"
      assert category.user_id == scope.user.id
    end

    test "create_category/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.create_category(scope, @invalid_attrs)
    end

    test "update_category/3 with valid data updates the category" do
      scope = user_scope_fixture()
      category = category_fixture(scope)
      update_attrs = %{name: "some updated name", slug: "some updated slug", icon: "some updated icon"}

      assert {:ok, %Category{} = category} = Catalog.update_category(scope, category, update_attrs)
      assert category.name == "some updated name"
      assert category.slug == "some updated slug"
      assert category.icon == "some updated icon"
    end

    test "update_category/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      category = category_fixture(scope)

      assert_raise MatchError, fn ->
        Catalog.update_category(other_scope, category, %{})
      end
    end

    test "update_category/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      category = category_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Catalog.update_category(scope, category, @invalid_attrs)
      assert category == Catalog.get_category!(scope, category.id)
    end

    test "delete_category/2 deletes the category" do
      scope = user_scope_fixture()
      category = category_fixture(scope)
      assert {:ok, %Category{}} = Catalog.delete_category(scope, category)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_category!(scope, category.id) end
    end

    test "delete_category/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      category = category_fixture(scope)
      assert_raise MatchError, fn -> Catalog.delete_category(other_scope, category) end
    end

    test "change_category/2 returns a category changeset" do
      scope = user_scope_fixture()
      category = category_fixture(scope)
      assert %Ecto.Changeset{} = Catalog.change_category(scope, category)
    end
  end

  describe "listings" do
    alias Agora.Catalog.Listing

    import Agora.AccountsFixtures, only: [user_scope_fixture: 0]
    import Agora.CatalogFixtures

    @invalid_attrs %{status: nil, description: nil, title: nil, price_cents: nil}

    test "list_listings/1 returns all scoped listings" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      listing = listing_fixture(scope)
      other_listing = listing_fixture(other_scope)
      assert Catalog.list_listings(scope) == [listing]
      assert Catalog.list_listings(other_scope) == [other_listing]
    end

    test "get_listing!/2 returns the listing with given id" do
      scope = user_scope_fixture()
      listing = listing_fixture(scope)
      other_scope = user_scope_fixture()
      assert Catalog.get_listing!(scope, listing.id) == listing
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_listing!(other_scope, listing.id) end
    end

    test "create_listing/2 with valid data creates a listing" do
      valid_attrs = %{status: "some status", description: "some description", title: "some title", price_cents: 42}
      scope = user_scope_fixture()

      assert {:ok, %Listing{} = listing} = Catalog.create_listing(scope, valid_attrs)
      assert listing.status == "some status"
      assert listing.description == "some description"
      assert listing.title == "some title"
      assert listing.price_cents == 42
      assert listing.user_id == scope.user.id
    end

    test "create_listing/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.create_listing(scope, @invalid_attrs)
    end

    test "update_listing/3 with valid data updates the listing" do
      scope = user_scope_fixture()
      listing = listing_fixture(scope)
      update_attrs = %{status: "some updated status", description: "some updated description", title: "some updated title", price_cents: 43}

      assert {:ok, %Listing{} = listing} = Catalog.update_listing(scope, listing, update_attrs)
      assert listing.status == "some updated status"
      assert listing.description == "some updated description"
      assert listing.title == "some updated title"
      assert listing.price_cents == 43
    end

    test "update_listing/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      listing = listing_fixture(scope)

      assert_raise MatchError, fn ->
        Catalog.update_listing(other_scope, listing, %{})
      end
    end

    test "update_listing/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      listing = listing_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Catalog.update_listing(scope, listing, @invalid_attrs)
      assert listing == Catalog.get_listing!(scope, listing.id)
    end

    test "delete_listing/2 deletes the listing" do
      scope = user_scope_fixture()
      listing = listing_fixture(scope)
      assert {:ok, %Listing{}} = Catalog.delete_listing(scope, listing)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_listing!(scope, listing.id) end
    end

    test "delete_listing/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      listing = listing_fixture(scope)
      assert_raise MatchError, fn -> Catalog.delete_listing(other_scope, listing) end
    end

    test "change_listing/2 returns a listing changeset" do
      scope = user_scope_fixture()
      listing = listing_fixture(scope)
      assert %Ecto.Changeset{} = Catalog.change_listing(scope, listing)
    end
  end
end

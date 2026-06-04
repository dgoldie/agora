defmodule Agora.OrdersTest do
  use Agora.DataCase

  alias Agora.Orders

  describe "orders" do
    alias Agora.Orders.Order

    import Agora.AccountsFixtures, only: [user_scope_fixture: 0]
    import Agora.OrdersFixtures

    @invalid_attrs %{status: nil, stripe_session_id: nil, amount_cents: nil}

    test "list_orders/1 returns all scoped orders" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      order = order_fixture(scope)
      other_order = order_fixture(other_scope)
      assert Orders.list_orders(scope) == [order]
      assert Orders.list_orders(other_scope) == [other_order]
    end

    test "get_order!/2 returns the order with given id" do
      scope = user_scope_fixture()
      order = order_fixture(scope)
      other_scope = user_scope_fixture()
      assert Orders.get_order!(scope, order.id) == order
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(other_scope, order.id) end
    end

    test "create_order/2 with valid data creates a order" do
      valid_attrs = %{status: "some status", stripe_session_id: "some stripe_session_id", amount_cents: 42}
      scope = user_scope_fixture()

      assert {:ok, %Order{} = order} = Orders.create_order(scope, valid_attrs)
      assert order.status == "some status"
      assert order.stripe_session_id == "some stripe_session_id"
      assert order.amount_cents == 42
      assert order.user_id == scope.user.id
    end

    test "create_order/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.create_order(scope, @invalid_attrs)
    end

    test "update_order/3 with valid data updates the order" do
      scope = user_scope_fixture()
      order = order_fixture(scope)
      update_attrs = %{status: "some updated status", stripe_session_id: "some updated stripe_session_id", amount_cents: 43}

      assert {:ok, %Order{} = order} = Orders.update_order(scope, order, update_attrs)
      assert order.status == "some updated status"
      assert order.stripe_session_id == "some updated stripe_session_id"
      assert order.amount_cents == 43
    end

    test "update_order/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      order = order_fixture(scope)

      assert_raise MatchError, fn ->
        Orders.update_order(other_scope, order, %{})
      end
    end

    test "update_order/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      order = order_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Orders.update_order(scope, order, @invalid_attrs)
      assert order == Orders.get_order!(scope, order.id)
    end

    test "delete_order/2 deletes the order" do
      scope = user_scope_fixture()
      order = order_fixture(scope)
      assert {:ok, %Order{}} = Orders.delete_order(scope, order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(scope, order.id) end
    end

    test "delete_order/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      order = order_fixture(scope)
      assert_raise MatchError, fn -> Orders.delete_order(other_scope, order) end
    end

    test "change_order/2 returns a order changeset" do
      scope = user_scope_fixture()
      order = order_fixture(scope)
      assert %Ecto.Changeset{} = Orders.change_order(scope, order)
    end
  end
end

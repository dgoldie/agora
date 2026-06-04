defmodule Agora.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Agora.Orders` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        amount_cents: 42,
        status: "some status",
        stripe_session_id: "some stripe_session_id"
      })

    {:ok, order} = Agora.Orders.create_order(scope, attrs)
    order
  end
end

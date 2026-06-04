defmodule Agora.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  alias Agora.Repo
  alias Agora.Orders.Order
  alias Agora.Accounts.Scope

  def list_orders_for_buyer(%Scope{} = scope) do
    Repo.all(
      from o in Order,
        where: o.buyer_id == ^scope.user.id,
        order_by: [desc: o.inserted_at],
        preload: [listing: [:category, :seller]]
    )
  end

  def get_order!(id), do: Repo.get!(Order, id)

  def get_order_by_session!(session_id) do
    Repo.get_by!(Order, stripe_session_id: session_id)
  end

  def create_order(%Scope{} = scope, attrs) do
    %Order{buyer_id: scope.user.id}
    |> Order.changeset(attrs)
    |> Repo.insert()
  end

  def mark_paid(%Order{} = order) do
    order
    |> Order.changeset(%{status: "paid"})
    |> Repo.update()
  end

  def mark_cancelled(%Order{} = order) do
    order
    |> Order.changeset(%{status: "cancelled"})
    |> Repo.update()
  end

  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end
end

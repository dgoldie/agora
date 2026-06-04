defmodule AgoraWeb.BuyerLive.Orders do
  use AgoraWeb, :live_view

  alias Agora.Orders

  def mount(_params, _session, socket) do
    orders = Orders.list_orders_for_buyer(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "My Orders")
     |> assign(:orders, orders)}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <h1 class="text-2xl font-bold">My Orders</h1>

      <div :if={@orders == []} class="text-center text-base-content/50 py-20">
        You have no orders yet.
        <.link navigate={~p"/listings"} class="link">Start browsing!</.link>
      </div>

      <div :if={@orders != []} class="space-y-4">
        <div :for={order <- @orders} class="card bg-base-100 border border-base-200">
          <div class="card-body p-4">
            <div class="flex items-start justify-between gap-4">
              <div>
                <.link navigate={~p"/listings/#{order.listing.id}"} class="link font-semibold">
                  {order.listing.title}
                </.link>
                <p class="text-sm text-base-content/60">
                  Sold by {order.listing.seller.display_name || order.listing.seller.email}
                </p>
              </div>
              <span class={"badge #{status_badge(order.status)} badge-lg"}>{order.status}</span>
            </div>
            <div class="flex items-center gap-4 mt-2 text-sm text-base-content/60">
              <span class="font-bold text-base text-base-content">{format_price(order.amount_cents)}</span>
              <span>Ordered {Calendar.strftime(order.inserted_at, "%b %d, %Y")}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp status_badge("paid"), do: "badge-success"
  defp status_badge("pending"), do: "badge-warning"
  defp status_badge("cancelled"), do: "badge-error"
  defp status_badge(_), do: "badge-ghost"

  defp format_price(cents) when is_integer(cents) do
    dollars = cents / 100
    :erlang.float_to_binary(dollars, decimals: 2) |> then(&"$#{&1}")
  end
end

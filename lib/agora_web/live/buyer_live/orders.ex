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

  def handle_params(%{"payment" => "success"}, _uri, socket) do
    {:noreply, put_flash(socket, :info, "Payment successful! Your order is confirmed.")}
  end

  def handle_params(%{"payment" => "cancelled"}, _uri, socket) do
    {:noreply, put_flash(socket, :info, "Payment cancelled.")}
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  def render(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto space-y-8">
      <div>
        <h1 class="text-3xl font-bold">My Orders</h1>
        <p class="text-base-content/50 text-sm mt-1">
          {length(@orders)} order{if length(@orders) != 1, do: "s"}
        </p>
      </div>

      <%!-- Empty state --%>
      <div :if={@orders == []} class="text-center py-24 space-y-4">
        <div class="text-6xl">🛍️</div>
        <h3 class="text-xl font-semibold">No orders yet</h3>
        <p class="text-base-content/60">Find something you love and make your first purchase.</p>
        <.link navigate={~p"/listings"} class="btn btn-primary rounded-full mt-2">
          <.icon name="hero-magnifying-glass-micro" class="size-4" /> Browse listings
        </.link>
      </div>

      <%!-- Order cards --%>
      <div :if={@orders != []} class="space-y-4">
        <div :for={order <- @orders} class="card bg-base-100 border border-base-200 rounded-2xl overflow-hidden hover:shadow-md transition-shadow">
          <div class="card-body p-0">
            <div class="flex">
              <%!-- Status stripe --%>
              <div class={"w-1.5 shrink-0 #{status_stripe(order.status)}"} />

              <%!-- Content --%>
              <div class="flex-1 p-5">
                <div class="flex items-start justify-between gap-4">
                  <div class="flex items-center gap-4">
                    <div class="w-14 h-14 rounded-xl overflow-hidden bg-base-200 shrink-0">
                      <img
                        :if={order.listing.image_url}
                        src={order.listing.image_url}
                        alt={order.listing.title}
                        class="w-full h-full object-cover"
                      />
                      <div :if={!order.listing.image_url} class="w-full h-full flex items-center justify-center text-2xl">🏷️</div>
                    </div>
                    <div>
                      <.link navigate={~p"/listings/#{order.listing.id}"} class="font-semibold hover:text-primary transition-colors line-clamp-1">
                        {order.listing.title}
                      </.link>
                      <p class="text-xs text-base-content/50 mt-0.5">
                        from {order.listing.seller.display_name || order.listing.seller.email}
                      </p>
                    </div>
                  </div>
                  <span class={"badge #{status_badge(order.status)} font-medium shrink-0"}>
                    {status_label(order.status)}
                  </span>
                </div>

                <div class="divider my-3" />

                <div class="flex items-center justify-between text-sm">
                  <div class="flex items-center gap-4 text-base-content/60">
                    <span><.icon name="hero-calendar-micro" class="size-4 inline mr-1" />{Calendar.strftime(order.inserted_at, "%b %d, %Y")}</span>
                  </div>
                  <span class="text-lg font-black text-primary">{format_price(order.amount_cents)}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp status_badge("paid"), do: "badge-success"
  defp status_badge("pending"), do: "badge-warning"
  defp status_badge("cancelled"), do: "badge-ghost"
  defp status_badge(_), do: "badge-ghost"

  defp status_label("paid"), do: "✓ Paid"
  defp status_label("pending"), do: "⏳ Pending"
  defp status_label("cancelled"), do: "Cancelled"
  defp status_label(s), do: s

  defp status_stripe("paid"), do: "bg-success"
  defp status_stripe("pending"), do: "bg-warning"
  defp status_stripe("cancelled"), do: "bg-base-300"
  defp status_stripe(_), do: "bg-base-300"

  defp format_price(cents) when is_integer(cents) do
    dollars = cents / 100
    :erlang.float_to_binary(dollars, decimals: 2) |> then(&"$#{&1}")
  end
end

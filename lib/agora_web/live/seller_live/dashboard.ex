defmodule AgoraWeb.SellerLive.Dashboard do
  use AgoraWeb, :live_view

  alias Agora.Catalog

  def mount(_params, _session, socket) do
    listings = Catalog.list_listings_for_seller(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "My Listings")
     |> assign(:listings, listings)}
  end

  def handle_event("set_status", %{"id" => id, "status" => status}, socket) do
    listing = Catalog.get_listing!(id)
    case Catalog.update_listing(socket.assigns.current_scope, listing, %{status: status}) do
      {:ok, _} ->
        listings = Catalog.list_listings_for_seller(socket.assigns.current_scope)
        {:noreply, assign(socket, :listings, listings)}
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not update listing.")}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    listing = Catalog.get_listing!(id)
    case Catalog.delete_listing(socket.assigns.current_scope, listing) do
      {:ok, _} ->
        listings = Catalog.list_listings_for_seller(socket.assigns.current_scope)
        {:noreply, socket |> put_flash(:info, "Listing deleted.") |> assign(:listings, listings)}
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not delete listing.")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-3xl font-bold">My Listings</h1>
          <p class="text-base-content/50 text-sm mt-1">Manage everything you're selling</p>
        </div>
        <.link navigate={~p"/listings/new"} class="btn btn-primary rounded-full">
          <.icon name="hero-plus-micro" class="size-4" /> New Listing
        </.link>
      </div>

      <%!-- Stats row --%>
      <div class="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <div class="stat bg-base-100 border border-base-200 rounded-2xl p-4">
          <div class="stat-title text-xs">Total</div>
          <div class="stat-value text-2xl">{length(@listings)}</div>
        </div>
        <div class="stat bg-success/10 border border-success/20 rounded-2xl p-4">
          <div class="stat-title text-xs text-success">Active</div>
          <div class="stat-value text-2xl text-success">{Enum.count(@listings, &(&1.status == "active"))}</div>
        </div>
        <div class="stat bg-warning/10 border border-warning/20 rounded-2xl p-4">
          <div class="stat-title text-xs text-warning">Draft</div>
          <div class="stat-value text-2xl text-warning">{Enum.count(@listings, &(&1.status == "draft"))}</div>
        </div>
        <div class="stat bg-error/10 border border-error/20 rounded-2xl p-4">
          <div class="stat-title text-xs text-error">Sold</div>
          <div class="stat-value text-2xl text-error">{Enum.count(@listings, &(&1.status == "sold"))}</div>
        </div>
      </div>

      <%!-- Empty state --%>
      <div :if={@listings == []} class="text-center py-24 space-y-4">
        <div class="text-6xl">🏷️</div>
        <h3 class="text-xl font-semibold">No listings yet</h3>
        <p class="text-base-content/60">Create your first listing and start selling today.</p>
        <.link navigate={~p"/listings/new"} class="btn btn-primary rounded-full mt-2">Create a listing</.link>
      </div>

      <%!-- Listings table --%>
      <div :if={@listings != []} class="card bg-base-100 border border-base-200 rounded-2xl overflow-hidden">
        <div class="overflow-x-auto">
          <table class="table">
            <thead>
              <tr class="bg-base-200/50 text-xs uppercase tracking-wide">
                <th>Listing</th>
                <th>Price</th>
                <th>Status</th>
                <th class="text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={listing <- @listings} class="hover border-b border-base-200 last:border-0">
                <td>
                  <div class="flex items-center gap-3">
                    <div class="w-12 h-12 rounded-lg overflow-hidden bg-base-200 shrink-0">
                      <img :if={listing.image_url} src={listing.image_url} alt={listing.title} class="w-full h-full object-cover" />
                      <div :if={!listing.image_url} class="w-full h-full flex items-center justify-center text-xl">🏷️</div>
                    </div>
                    <div>
                      <.link navigate={~p"/listings/#{listing.id}"} class="font-semibold hover:text-primary transition-colors line-clamp-1">
                        {listing.title}
                      </.link>
                      <p class="text-xs text-base-content/50">{listing.category.name}</p>
                    </div>
                  </div>
                </td>
                <td class="font-bold text-primary">{format_price(listing.price_cents)}</td>
                <td>
                  <span class={"badge badge-sm #{status_badge(listing.status)} font-medium"}>
                    {listing.status}
                  </span>
                </td>
                <td>
                  <div class="flex gap-1 justify-end">
                    <button
                      :if={listing.status == "draft"}
                      phx-click="set_status" phx-value-id={listing.id} phx-value-status="active"
                      class="btn btn-xs btn-success rounded-full"
                    >Publish</button>
                    <button
                      :if={listing.status == "active"}
                      phx-click="set_status" phx-value-id={listing.id} phx-value-status="draft"
                      class="btn btn-xs btn-warning rounded-full"
                    >Unpublish</button>
                    <button
                      phx-click="delete" phx-value-id={listing.id}
                      data-confirm="Delete this listing?"
                      class="btn btn-xs btn-ghost text-error rounded-full"
                    >
                      <.icon name="hero-trash-micro" class="size-3" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  defp status_badge("active"), do: "badge-success"
  defp status_badge("draft"), do: "badge-warning"
  defp status_badge("sold"), do: "badge-error"
  defp status_badge(_), do: "badge-ghost"

  defp format_price(cents) when is_integer(cents) do
    dollars = cents / 100
    :erlang.float_to_binary(dollars, decimals: 2) |> then(&"$#{&1}")
  end
end

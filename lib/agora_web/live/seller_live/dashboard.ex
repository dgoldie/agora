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

      {:error, _changeset} ->
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
    <div class="space-y-6">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-bold">My Listings</h1>
        <.link navigate={~p"/listings/new"} class="btn btn-primary btn-sm">+ New Listing</.link>
      </div>

      <div :if={@listings == []} class="text-center text-base-content/50 py-20">
        You have no listings yet.
        <.link navigate={~p"/listings/new"} class="link">Create your first one!</.link>
      </div>

      <div :if={@listings != []} class="overflow-x-auto">
        <table class="table">
          <thead>
            <tr>
              <th>Title</th>
              <th>Category</th>
              <th>Price</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={listing <- @listings} class="hover">
              <td>
                <.link navigate={~p"/listings/#{listing.id}"} class="link link-hover font-medium">
                  {listing.title}
                </.link>
              </td>
              <td>{listing.category.name}</td>
              <td>{format_price(listing.price_cents)}</td>
              <td><span class={"badge #{status_badge(listing.status)}"}>{listing.status}</span></td>
              <td>
                <div class="flex gap-2">
                  <%= if listing.status == "draft" do %>
                    <button
                      phx-click="set_status"
                      phx-value-id={listing.id}
                      phx-value-status="active"
                      class="btn btn-xs btn-success"
                    >
                      Publish
                    </button>
                  <% end %>
                  <%= if listing.status == "active" do %>
                    <button
                      phx-click="set_status"
                      phx-value-id={listing.id}
                      phx-value-status="draft"
                      class="btn btn-xs btn-warning"
                    >
                      Unpublish
                    </button>
                  <% end %>
                  <button
                    phx-click="delete"
                    phx-value-id={listing.id}
                    data-confirm="Delete this listing?"
                    class="btn btn-xs btn-error btn-outline"
                  >
                    Delete
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  defp status_badge("active"), do: "badge-success"
  defp status_badge("draft"), do: "badge-ghost"
  defp status_badge("sold"), do: "badge-error"
  defp status_badge(_), do: "badge-ghost"

  defp format_price(cents) when is_integer(cents) do
    dollars = cents / 100
    :erlang.float_to_binary(dollars, decimals: 2) |> then(&"$#{&1}")
  end
end

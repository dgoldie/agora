defmodule AgoraWeb.HomeLive do
  use AgoraWeb, :live_view

  alias Agora.Catalog

  def mount(_params, _session, socket) do
    categories = Catalog.list_categories()
    listings = Catalog.list_listings(status: "active")

    {:ok,
     socket
     |> assign(:page_title, "Agora — Buy and Sell Anything")
     |> assign(:categories, categories)
     |> assign(:listings, listings)}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-10">
      <section class="text-center py-12">
        <h1 class="text-4xl font-bold mb-4">Buy and Sell Anything</h1>
        <p class="text-base-content/60 text-lg mb-6">
          Discover unique items or list your own in minutes.
        </p>
        <div class="flex justify-center gap-3">
          <.link navigate={~p"/listings"} class="btn btn-primary">Browse Listings</.link>
          <%= if @current_scope && @current_scope.user do %>
            <.link navigate={~p"/listings/new"} class="btn btn-outline">Sell Something</.link>
          <% else %>
            <.link navigate={~p"/users/register"} class="btn btn-outline">Start Selling</.link>
          <% end %>
        </div>
      </section>

      <section :if={@categories != []}>
        <h2 class="text-xl font-semibold mb-4">Browse by Category</h2>
        <div class="flex flex-wrap gap-2">
          <.link
            :for={cat <- @categories}
            navigate={~p"/listings?category_id=#{cat.id}"}
            class="badge badge-outline badge-lg gap-1 cursor-pointer hover:badge-primary"
          >
            <%= if cat.icon, do: cat.icon %> {cat.name}
          </.link>
        </div>
      </section>

      <section :if={@listings != []}>
        <h2 class="text-xl font-semibold mb-4">Recent Listings</h2>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          <.listing_card :for={listing <- @listings} listing={listing} />
        </div>
      </section>

      <section :if={@listings == []}>
        <p class="text-center text-base-content/50 py-20">
          No listings yet. <.link navigate={~p"/listings/new"} class="link">Be the first to sell!</.link>
        </p>
      </section>
    </div>
    """
  end

  defp listing_card(assigns) do
    ~H"""
    <.link navigate={~p"/listings/#{@listing.id}"} class="card bg-base-100 border border-base-200 hover:border-primary transition-colors cursor-pointer">
      <div class="card-body p-4">
        <h3 class="card-title text-base line-clamp-2">{@listing.title}</h3>
        <p class="text-base-content/60 text-sm line-clamp-2">{@listing.description}</p>
        <div class="flex items-center justify-between mt-2">
          <span class="text-lg font-bold text-primary">{format_price(@listing.price_cents)}</span>
          <span class="badge badge-ghost badge-sm">{@listing.category.name}</span>
        </div>
      </div>
    </.link>
    """
  end

  defp format_price(cents) when is_integer(cents) do
    dollars = cents / 100
    :erlang.float_to_binary(dollars, decimals: 2) |> then(&"$#{&1}")
  end
end

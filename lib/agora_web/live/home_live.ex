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
    <div class="space-y-16">
      <%!-- Hero --%>
      <section class="relative rounded-3xl overflow-hidden bg-gradient-to-br from-primary to-accent px-8 py-20 text-center text-primary-content shadow-xl">
        <div class="absolute inset-0 opacity-10 bg-[radial-gradient(circle_at_30%_20%,white,transparent_60%)]" />
        <div class="relative space-y-6 max-w-2xl mx-auto">
          <div class="badge badge-ghost badge-lg font-medium opacity-80">✨ The marketplace for everything</div>
          <h1 class="text-5xl sm:text-6xl font-black tracking-tight leading-tight">
            Buy and Sell<br /><span class="opacity-90">Anything.</span>
          </h1>
          <p class="text-lg opacity-80">
            Discover unique items from sellers near you — or list your own in under a minute.
          </p>
          <div class="flex flex-wrap justify-center gap-3 pt-2">
            <.link navigate={~p"/listings"} class="btn btn-neutral btn-lg rounded-full shadow-lg">
              <.icon name="hero-magnifying-glass-micro" class="size-5" /> Browse listings
            </.link>
            <%= if @current_scope && @current_scope.user do %>
              <.link navigate={~p"/listings/new"} class="btn btn-outline btn-lg rounded-full border-white/40 text-white hover:bg-white/20 hover:border-white">
                <.icon name="hero-plus-micro" class="size-5" /> Sell something
              </.link>
            <% else %>
              <.link navigate={~p"/users/register"} class="btn btn-outline btn-lg rounded-full border-white/40 text-white hover:bg-white/20 hover:border-white">
                Start selling free
              </.link>
            <% end %>
          </div>
        </div>
      </section>

      <%!-- Categories --%>
      <section :if={@categories != []}>
        <div class="flex items-center justify-between mb-5">
          <h2 class="text-2xl font-bold">Browse by Category</h2>
          <.link navigate={~p"/listings"} class="link link-primary text-sm">View all</.link>
        </div>
        <div class="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-8 gap-3">
          <.link
            :for={cat <- @categories}
            navigate={~p"/listings?category_id=#{cat.id}"}
            class="card bg-base-200 hover:bg-primary hover:text-primary-content transition-all duration-200 cursor-pointer group shadow-sm hover:shadow-md hover:-translate-y-0.5"
          >
            <div class="card-body items-center text-center p-4 gap-2">
              <span class="text-3xl">{cat.icon}</span>
              <span class="text-xs font-semibold leading-tight">{cat.name}</span>
            </div>
          </.link>
        </div>
      </section>

      <%!-- Recent listings --%>
      <section :if={@listings != []}>
        <div class="flex items-center justify-between mb-5">
          <h2 class="text-2xl font-bold">Recent Listings</h2>
          <.link navigate={~p"/listings"} class="link link-primary text-sm">See all</.link>
        </div>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
          <.listing_card :for={listing <- Enum.take(@listings, 8)} listing={listing} />
        </div>
      </section>

      <%!-- Empty state --%>
      <section :if={@listings == []} class="text-center py-24 space-y-4">
        <div class="text-6xl">🛍️</div>
        <h3 class="text-xl font-semibold">No listings yet</h3>
        <p class="text-base-content/60">Be the first to sell something on Agora.</p>
        <.link navigate={~p"/listings/new"} class="btn btn-primary rounded-full mt-2">
          Create a listing
        </.link>
      </section>

      <%!-- How it works --%>
      <section class="grid grid-cols-1 sm:grid-cols-3 gap-6 text-center py-4">
        <div class="space-y-3">
          <div class="mx-auto w-14 h-14 rounded-2xl bg-primary/10 flex items-center justify-center text-2xl">📸</div>
          <h3 class="font-bold">List in minutes</h3>
          <p class="text-sm text-base-content/60">Add a photo, description, and price. Your listing goes live instantly.</p>
        </div>
        <div class="space-y-3">
          <div class="mx-auto w-14 h-14 rounded-2xl bg-accent/10 flex items-center justify-center text-2xl">💬</div>
          <h3 class="font-bold">Connect with buyers</h3>
          <p class="text-sm text-base-content/60">Buyers find your item and purchase securely via Stripe.</p>
        </div>
        <div class="space-y-3">
          <div class="mx-auto w-14 h-14 rounded-2xl bg-success/10 flex items-center justify-center text-2xl">💸</div>
          <h3 class="font-bold">Get paid</h3>
          <p class="text-sm text-base-content/60">Funds hit your account once the buyer completes checkout.</p>
        </div>
      </section>
    </div>
    """
  end

  defp listing_card(assigns) do
    ~H"""
    <.link
      navigate={~p"/listings/#{@listing.id}"}
      class="listing-card card bg-base-100 border border-base-200 hover:border-primary/30 cursor-pointer overflow-hidden"
    >
      <figure class="bg-base-200 aspect-square overflow-hidden">
        <img
          :if={@listing.image_url}
          src={@listing.image_url}
          alt={@listing.title}
          class="w-full h-full object-cover"
        />
        <div :if={!@listing.image_url} class="w-full h-full flex items-center justify-center text-5xl text-base-content/20">
          🏷️
        </div>
      </figure>
      <div class="card-body p-4 gap-2">
        <div class="flex items-start justify-between gap-2">
          <h3 class="font-semibold text-sm leading-tight line-clamp-2">{@listing.title}</h3>
          <span class="badge badge-ghost badge-sm shrink-0">{@listing.category.name}</span>
        </div>
        <p class="text-base-content/50 text-xs line-clamp-1">{@listing.description}</p>
        <p class="text-primary font-bold text-lg mt-1">{format_price(@listing.price_cents)}</p>
      </div>
    </.link>
    """
  end

  defp format_price(cents) when is_integer(cents) do
    dollars = cents / 100
    :erlang.float_to_binary(dollars, decimals: 2) |> then(&"$#{&1}")
  end
end

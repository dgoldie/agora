defmodule AgoraWeb.ListingLive.Index do
  use AgoraWeb, :live_view

  alias Agora.Catalog

  def mount(_params, _session, socket) do
    categories = Catalog.list_categories()

    {:ok,
     socket
     |> assign(:page_title, "Browse Listings")
     |> assign(:categories, categories)
     |> assign(:category_id, nil)
     |> assign(:search, "")
     |> assign(:listings, [])}
  end

  def handle_params(params, _uri, socket) do
    category_id = params["category_id"]
    search = params["search"] || ""

    listings =
      Catalog.list_listings(
        category_id: category_id,
        search: search,
        status: "active"
      )

    {:noreply,
     socket
     |> assign(:category_id, category_id)
     |> assign(:search, search)
     |> assign(:listings, listings)}
  end

  def handle_event("search", %{"search" => search}, socket) do
    params = %{search: search, category_id: socket.assigns.category_id}
    {:noreply, push_patch(socket, to: ~p"/listings?#{params}")}
  end

  def handle_event("filter_category", %{"id" => id}, socket) do
    id = if id == "", do: nil, else: id
    params = %{category_id: id, search: socket.assigns.search}
    {:noreply, push_patch(socket, to: ~p"/listings?#{params}")}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex flex-col sm:flex-row gap-4 items-start sm:items-center justify-between">
        <h1 class="text-2xl font-bold">Browse Listings</h1>
        <.link :if={@current_scope && @current_scope.user} navigate={~p"/listings/new"} class="btn btn-primary btn-sm">
          + New Listing
        </.link>
      </div>

      <form phx-submit="search" class="flex gap-2">
        <input
          type="text"
          name="search"
          value={@search}
          placeholder="Search listings..."
          class="input input-bordered flex-1"
        />
        <button type="submit" class="btn btn-primary">Search</button>
      </form>

      <div class="flex flex-wrap gap-2">
        <button
          phx-click="filter_category"
          phx-value-id=""
          class={"badge badge-lg cursor-pointer #{if is_nil(@category_id), do: "badge-primary", else: "badge-outline"}"}
        >
          All
        </button>
        <button
          :for={cat <- @categories}
          phx-click="filter_category"
          phx-value-id={cat.id}
          class={"badge badge-lg cursor-pointer #{if to_string(@category_id) == to_string(cat.id), do: "badge-primary", else: "badge-outline"}"}
        >
          <%= if cat.icon, do: cat.icon %> {cat.name}
        </button>
      </div>

      <div :if={@listings != []} class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        <.link
          :for={listing <- @listings}
          navigate={~p"/listings/#{listing.id}"}
          class="card bg-base-100 border border-base-200 hover:border-primary transition-colors"
        >
          <div class="card-body p-4">
            <h3 class="card-title text-base line-clamp-2">{listing.title}</h3>
            <p class="text-base-content/60 text-sm line-clamp-2">{listing.description}</p>
            <div class="flex items-center justify-between mt-2">
              <span class="text-lg font-bold text-primary">{format_price(listing.price_cents)}</span>
              <span class="badge badge-ghost badge-sm">{listing.category.name}</span>
            </div>
          </div>
        </.link>
      </div>

      <p :if={@listings == []} class="text-center text-base-content/50 py-20">
        No listings found. Try a different search or category.
      </p>
    </div>
    """
  end

  defp format_price(cents) when is_integer(cents) do
    dollars = cents / 100
    :erlang.float_to_binary(dollars, decimals: 2) |> then(&"$#{&1}")
  end
end

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
        <div>
          <h1 class="text-3xl font-bold">Browse Listings</h1>
          <p class="text-base-content/50 text-sm mt-1">{length(@listings)} listing{if length(@listings) != 1, do: "s"} found</p>
        </div>
        <.link :if={@current_scope && @current_scope.user} navigate={~p"/listings/new"} class="btn btn-primary rounded-full shrink-0">
          <.icon name="hero-plus-micro" class="size-4" /> New Listing
        </.link>
      </div>

      <%!-- Search bar --%>
      <form phx-submit="search" class="join w-full max-w-xl">
        <input
          type="text"
          name="search"
          value={@search}
          placeholder="Search listings..."
          class="input input-bordered join-item flex-1"
        />
        <button type="submit" class="btn btn-primary join-item">
          <.icon name="hero-magnifying-glass-micro" class="size-4" />
        </button>
      </form>

      <%!-- Category filter strip --%>
      <div class="flex flex-wrap gap-2">
        <button
          phx-click="filter_category"
          phx-value-id=""
          class={"btn btn-sm rounded-full #{if is_nil(@category_id), do: "btn-primary", else: "btn-ghost border border-base-300"}"}
        >
          All
        </button>
        <button
          :for={cat <- @categories}
          phx-click="filter_category"
          phx-value-id={cat.id}
          class={"btn btn-sm rounded-full #{if to_string(@category_id) == to_string(cat.id), do: "btn-primary", else: "btn-ghost border border-base-300"}"}
        >
          {cat.icon} {cat.name}
        </button>
      </div>

      <%!-- Active filter banner --%>
      <div :if={@search != "" || @category_id} class="alert alert-info py-2 text-sm flex items-center gap-2">
        <.icon name="hero-funnel-micro" class="size-4 shrink-0" />
        <span>
          Filtering by
          <strong :if={@category_id}>{Enum.find(@categories, &(to_string(&1.id) == to_string(@category_id))) |> then(&(&1 && &1.name))}</strong>
          <span :if={@category_id && @search != ""}> + </span>
          <strong :if={@search != ""}>"{@search}"</strong>
        </span>
        <.link patch={~p"/listings"} class="btn btn-xs btn-ghost ml-auto">Clear</.link>
      </div>

      <%!-- Grid --%>
      <div :if={@listings != []} class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
        <.link
          :for={listing <- @listings}
          navigate={~p"/listings/#{listing.id}"}
          class="listing-card card bg-base-100 border border-base-200 hover:border-primary/30 cursor-pointer overflow-hidden"
        >
          <figure class="bg-base-200 aspect-square overflow-hidden">
            <img
              :if={listing.image_url}
              src={listing.image_url}
              alt={listing.title}
              class="w-full h-full object-cover"
            />
            <div :if={!listing.image_url} class="w-full h-full flex items-center justify-center text-5xl text-base-content/20">
              🏷️
            </div>
          </figure>
          <div class="card-body p-4 gap-2">
            <div class="flex items-start justify-between gap-2">
              <h3 class="font-semibold text-sm leading-tight line-clamp-2">{listing.title}</h3>
              <span class="badge badge-ghost badge-sm shrink-0">{listing.category.name}</span>
            </div>
            <p class="text-base-content/50 text-xs line-clamp-1">{listing.description}</p>
            <p class="text-primary font-bold text-lg mt-1">{format_price(listing.price_cents)}</p>
          </div>
        </.link>
      </div>

      <%!-- Empty state --%>
      <div :if={@listings == []} class="text-center py-24 space-y-4">
        <div class="text-6xl">🔍</div>
        <h3 class="text-xl font-semibold">No listings found</h3>
        <p class="text-base-content/60">Try a different search term or category.</p>
        <.link patch={~p"/listings"} class="btn btn-ghost rounded-full mt-2">Clear filters</.link>
      </div>
    </div>
    """
  end

  defp format_price(cents) when is_integer(cents) do
    dollars = cents / 100
    :erlang.float_to_binary(dollars, decimals: 2) |> then(&"$#{&1}")
  end
end

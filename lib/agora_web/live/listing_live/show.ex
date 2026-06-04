defmodule AgoraWeb.ListingLive.Show do
  use AgoraWeb, :live_view

  alias Agora.{Catalog, Payments}

  def mount(%{"id" => id}, _session, socket) do
    listing = Catalog.get_listing!(id)

    {:ok,
     socket
     |> assign(:page_title, listing.title)
     |> assign(:listing, listing)}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto space-y-6">
      <.link navigate={~p"/listings"} class="btn btn-ghost btn-sm">
        &larr; Back to listings
      </.link>

      <div class="card bg-base-100 border border-base-200">
        <div class="card-body space-y-4">
          <div class="flex items-start justify-between gap-4">
            <h1 class="text-2xl font-bold">{@listing.title}</h1>
            <span class="badge badge-ghost">{@listing.category.name}</span>
          </div>

          <p class="text-3xl font-bold text-primary">{format_price(@listing.price_cents)}</p>

          <p class="text-base-content/80 whitespace-pre-wrap">{@listing.description}</p>

          <div class="divider" />

          <div class="text-sm text-base-content/50">
            Listed by <strong>{@listing.seller.display_name || @listing.seller.email}</strong>
          </div>

          <div class="card-actions">
            <%= cond do %>
              <% @listing.status == "sold" -> %>
                <span class="badge badge-error badge-lg">Sold</span>

              <% is_own_listing?(@current_scope, @listing) -> %>
                <.link navigate={~p"/my/listings"} class="btn btn-outline btn-sm">
                  Manage your listings
                </.link>

              <% @current_scope && @current_scope.user -> %>
                <button class="btn btn-primary" phx-click="buy_now">
                  Buy Now
                </button>

              <% true -> %>
                <.link navigate={~p"/users/log-in"} class="btn btn-primary">
                  Log in to buy
                </.link>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("buy_now", _params, socket) do
    case Payments.create_checkout_session(socket.assigns.current_scope, socket.assigns.listing) do
      {:ok, checkout_url} ->
        {:noreply, redirect(socket, external: checkout_url)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Could not start checkout. Please try again.")}
    end
  end

  defp is_own_listing?(nil, _listing), do: false
  defp is_own_listing?(scope, listing), do: scope.user && scope.user.id == listing.seller_id

  defp format_price(cents) when is_integer(cents) do
    dollars = cents / 100
    :erlang.float_to_binary(dollars, decimals: 2) |> then(&"$#{&1}")
  end
end

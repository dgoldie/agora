defmodule AgoraWeb.ListingLive.Show do
  use AgoraWeb, :live_view

  alias Agora.{Catalog, Payments, Reviews}
  alias Agora.Reviews.Review

  def mount(%{"id" => id}, _session, socket) do
    listing = Catalog.get_listing!(id)
    reviews = Reviews.list_reviews_for_listing(listing.id)
    avg = Reviews.average_rating(listing.id)
    review_form = to_form(Reviews.change_review(%Review{}), as: :review)

    {:ok,
     socket
     |> assign(:page_title, listing.title)
     |> assign(:listing, listing)
     |> assign(:reviews, reviews)
     |> assign(:avg_rating, avg && Float.round(avg / 1, 1))
     |> assign(:review_form, review_form)
     |> assign(:show_review_form, false)}
  end

  def handle_event("buy_now", _params, socket) do
    case Payments.create_checkout_session(socket.assigns.current_scope, socket.assigns.listing) do
      {:ok, checkout_url} ->
        {:noreply, redirect(socket, external: checkout_url)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Could not start checkout. Please try again.")}
    end
  end

  def handle_event("toggle_review_form", _params, socket) do
    {:noreply, update(socket, :show_review_form, &(!&1))}
  end

  def handle_event("validate_review", %{"review" => params}, socket) do
    changeset =
      %Review{}
      |> Reviews.change_review(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :review_form, to_form(changeset, as: :review))}
  end

  def handle_event("submit_review", %{"review" => params}, socket) do
    listing = socket.assigns.listing

    case Reviews.create_review(socket.assigns.current_scope, listing.id, params) do
      {:ok, _review} ->
        reviews = Reviews.list_reviews_for_listing(listing.id)
        avg = Reviews.average_rating(listing.id)

        {:noreply,
         socket
         |> put_flash(:info, "Review submitted!")
         |> assign(:reviews, reviews)
         |> assign(:avg_rating, avg && Float.round(avg / 1, 1))
         |> assign(:show_review_form, false)
         |> assign(:review_form, to_form(Reviews.change_review(%Review{}), as: :review))}

      {:error, changeset} ->
        {:noreply, assign(socket, :review_form, to_form(changeset, as: :review))}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto space-y-6">
      <.link navigate={~p"/listings"} class="btn btn-ghost btn-sm">
        &larr; Back to listings
      </.link>

      <div class="card bg-base-100 border border-base-200">
        <div class="card-body space-y-4">
          <img
            :if={@listing.image_url}
            src={@listing.image_url}
            alt={@listing.title}
            class="w-full max-h-80 object-cover rounded-lg"
          />

          <div class="flex items-start justify-between gap-4">
            <h1 class="text-2xl font-bold">{@listing.title}</h1>
            <span class="badge badge-ghost">{@listing.category.name}</span>
          </div>

          <div class="flex items-center gap-3">
            <p class="text-3xl font-bold text-primary">{format_price(@listing.price_cents)}</p>
            <div :if={@avg_rating} class="flex items-center gap-1 text-warning">
              <span>★</span>
              <span class="text-sm font-medium text-base-content">{@avg_rating} ({length(@reviews)} reviews)</span>
            </div>
          </div>

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

      <%!-- Reviews section --%>
      <div class="space-y-4">
        <div class="flex items-center justify-between">
          <h2 class="text-xl font-semibold">Reviews</h2>
          <button
            :if={can_review?(@current_scope, @listing)}
            phx-click="toggle_review_form"
            class="btn btn-outline btn-sm"
          >
            {if @show_review_form, do: "Cancel", else: "Write a Review"}
          </button>
        </div>

        <div :if={@show_review_form} class="card bg-base-100 border border-base-200">
          <div class="card-body">
            <.form for={@review_form} phx-change="validate_review" phx-submit="submit_review" class="space-y-3">
              <div class="form-control">
                <label class="label"><span class="label-text">Rating</span></label>
                <div class="flex gap-2">
                  <label :for={star <- 1..5} class="flex items-center gap-1 cursor-pointer">
                    <input
                      type="radio"
                      name={@review_form[:rating].name}
                      value={star}
                      checked={to_string(@review_form[:rating].value) == to_string(star)}
                      class="radio radio-warning radio-sm"
                    />
                    <span class="text-warning">{"★" |> String.duplicate(star)}</span>
                  </label>
                </div>
              </div>
              <.input field={@review_form[:body]} type="textarea" label="Your review (optional)" placeholder="Share your experience..." />
              <button type="submit" class="btn btn-primary btn-sm">Submit Review</button>
            </.form>
          </div>
        </div>

        <div :if={@reviews == []} class="text-base-content/50 text-sm">
          No reviews yet. Be the first!
        </div>

        <div :for={review <- @reviews} class="card bg-base-100 border border-base-200">
          <div class="card-body p-4">
            <div class="flex items-center justify-between">
              <span class="font-medium">{review.reviewer.display_name || review.reviewer.email}</span>
              <span class="text-warning">{"★" |> String.duplicate(review.rating)}<span class="text-base-content/40">{"★" |> String.duplicate(5 - review.rating)}</span></span>
            </div>
            <p :if={review.body} class="text-sm text-base-content/70 mt-1">{review.body}</p>
            <p class="text-xs text-base-content/40 mt-1">{Calendar.strftime(review.inserted_at, "%b %d, %Y")}</p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp is_own_listing?(nil, _listing), do: false
  defp is_own_listing?(scope, listing), do: scope.user && scope.user.id == listing.seller_id

  defp can_review?(nil, _listing), do: false
  defp can_review?(scope, listing), do: scope.user && scope.user.id != listing.seller_id

  defp format_price(cents) when is_integer(cents) do
    dollars = cents / 100
    :erlang.float_to_binary(dollars, decimals: 2) |> then(&"$#{&1}")
  end
end

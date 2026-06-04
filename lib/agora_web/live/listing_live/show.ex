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
      {:ok, checkout_url} -> {:noreply, redirect(socket, external: checkout_url)}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Could not start checkout. Please try again.")}
    end
  end

  def handle_event("toggle_review_form", _params, socket) do
    {:noreply, update(socket, :show_review_form, &(!&1))}
  end

  def handle_event("validate_review", %{"review" => params}, socket) do
    changeset = %Review{} |> Reviews.change_review(params) |> Map.put(:action, :validate)
    {:noreply, assign(socket, :review_form, to_form(changeset, as: :review))}
  end

  def handle_event("submit_review", %{"review" => params}, socket) do
    listing = socket.assigns.listing

    case Reviews.create_review(socket.assigns.current_scope, listing.id, params) do
      {:ok, _} ->
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
    <div class="max-w-4xl mx-auto space-y-8">
      <.link navigate={~p"/listings"} class="btn btn-ghost btn-sm rounded-full -ml-2">
        <.icon name="hero-arrow-left-micro" class="size-4" /> Back to listings
      </.link>

      <div class="grid grid-cols-1 lg:grid-cols-5 gap-8">
        <%!-- Left: image --%>
        <div class="lg:col-span-3">
          <div class="rounded-2xl overflow-hidden bg-base-200 aspect-square shadow-sm">
            <img
              :if={@listing.image_url}
              src={@listing.image_url}
              alt={@listing.title}
              class="w-full h-full object-cover"
            />
            <div :if={!@listing.image_url} class="w-full h-full flex items-center justify-center text-8xl text-base-content/10">
              🏷️
            </div>
          </div>
        </div>

        <%!-- Right: details --%>
        <div class="lg:col-span-2 space-y-5">
          <div>
            <div class="flex items-center gap-2 mb-2">
              <span class="badge badge-outline">{@listing.category.name}</span>
              <span :if={@listing.status == "sold"} class="badge badge-error">Sold</span>
            </div>
            <h1 class="text-2xl font-bold leading-tight">{@listing.title}</h1>

            <div class="flex items-center gap-2 mt-2">
              <p class="text-3xl font-black text-primary">{format_price(@listing.price_cents)}</p>
              <div :if={@avg_rating} class="flex items-center gap-1 ml-2">
                <span class="text-warning">★</span>
                <span class="text-sm font-medium">{@avg_rating}</span>
                <span class="text-xs text-base-content/50">({length(@reviews)})</span>
              </div>
            </div>
          </div>

          <%!-- Seller card --%>
          <div class="card bg-base-200 rounded-xl p-4">
            <div class="flex items-center gap-3">
              <div class="avatar placeholder">
                <div class="bg-primary text-primary-content rounded-full w-10 flex items-center justify-center font-bold">
                  {String.first(@listing.seller.display_name || @listing.seller.email) |> String.upcase()}
                </div>
              </div>
              <div>
                <p class="font-semibold text-sm">{@listing.seller.display_name || "Seller"}</p>
                <p class="text-xs text-base-content/50">{@listing.seller.email}</p>
              </div>
            </div>
            <p :if={@listing.seller.bio} class="text-sm text-base-content/70 mt-3 italic">"{@listing.seller.bio}"</p>
          </div>

          <%!-- CTA --%>
          <div class="space-y-2">
            <%= cond do %>
              <% @listing.status == "sold" -> %>
                <div class="alert alert-error">
                  <.icon name="hero-x-circle-micro" class="size-5" />
                  This item has been sold.
                </div>

              <% is_own_listing?(@current_scope, @listing) -> %>
                <.link navigate={~p"/my/listings"} class="btn btn-outline w-full rounded-full">
                  <.icon name="hero-pencil-square-micro" class="size-4" /> Manage your listings
                </.link>

              <% @current_scope && @current_scope.user -> %>
                <button class="btn btn-primary btn-lg w-full rounded-full shadow-lg" phx-click="buy_now">
                  <.icon name="hero-shopping-bag-micro" class="size-5" /> Buy Now
                </button>

              <% true -> %>
                <.link navigate={~p"/users/log-in"} class="btn btn-primary btn-lg w-full rounded-full">
                  Log in to buy
                </.link>
            <% end %>
          </div>

          <%!-- Description --%>
          <div class="divider" />
          <div>
            <h2 class="font-semibold text-sm text-base-content/60 uppercase tracking-wide mb-2">Description</h2>
            <p class="text-sm text-base-content/80 whitespace-pre-wrap leading-relaxed">{@listing.description}</p>
          </div>
        </div>
      </div>

      <%!-- Reviews section --%>
      <div class="divider" />
      <div class="space-y-5">
        <div class="flex items-center justify-between">
          <div>
            <h2 class="text-xl font-bold">Reviews</h2>
            <p :if={@avg_rating} class="text-sm text-base-content/50">
              <span class="text-warning">{"★" |> String.duplicate(round(@avg_rating))}</span>
              {@avg_rating} average · {length(@reviews)} review{if length(@reviews) != 1, do: "s"}
            </p>
          </div>
          <button
            :if={can_review?(@current_scope, @listing)}
            phx-click="toggle_review_form"
            class={"btn btn-sm rounded-full #{if @show_review_form, do: "btn-ghost", else: "btn-outline"}"}
          >
            {if @show_review_form, do: "Cancel", else: "Write a review"}
          </button>
        </div>

        <%!-- Review form --%>
        <div :if={@show_review_form} class="card bg-base-200 rounded-xl p-5">
          <.form for={@review_form} phx-change="validate_review" phx-submit="submit_review" class="space-y-4">
            <div class="form-control">
              <label class="label"><span class="label-text font-medium">Your rating</span></label>
              <div class="rating rating-lg">
                <input
                  :for={star <- 1..5}
                  type="radio"
                  name={@review_form[:rating].name}
                  value={star}
                  class="mask mask-star-2 bg-warning"
                  checked={to_string(@review_form[:rating].value) == to_string(star)}
                />
              </div>
            </div>
            <.input field={@review_form[:body]} type="textarea" label="Your review (optional)" placeholder="Share your experience with this item..." />
            <button type="submit" class="btn btn-primary rounded-full">Submit review</button>
          </.form>
        </div>

        <%!-- No reviews --%>
        <div :if={@reviews == [] && !@show_review_form} class="text-center py-10 space-y-2">
          <div class="text-4xl">💬</div>
          <p class="text-base-content/50">No reviews yet. Be the first!</p>
        </div>

        <%!-- Review list --%>
        <div class="space-y-3">
          <div :for={review <- @reviews} class="card bg-base-100 border border-base-200 rounded-xl p-4">
            <div class="flex items-center justify-between gap-3">
              <div class="flex items-center gap-3">
                <div class="avatar placeholder">
                  <div class="bg-base-300 text-base-content rounded-full w-9 flex items-center justify-center text-sm font-bold">
                    {String.first(review.reviewer.display_name || review.reviewer.email) |> String.upcase()}
                  </div>
                </div>
                <div>
                  <p class="font-semibold text-sm">{review.reviewer.display_name || review.reviewer.email}</p>
                  <p class="text-xs text-base-content/40">{Calendar.strftime(review.inserted_at, "%b %d, %Y")}</p>
                </div>
              </div>
              <div class="text-warning text-sm">
                {"★" |> String.duplicate(review.rating)}<span class="text-base-content/20">{"★" |> String.duplicate(5 - review.rating)}</span>
              </div>
            </div>
            <p :if={review.body} class="text-sm text-base-content/70 mt-3 leading-relaxed">{review.body}</p>
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

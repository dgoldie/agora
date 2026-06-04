defmodule Agora.Payments do
  @moduledoc """
  Stripe Checkout integration — session creation and webhook handling.
  """

  alias Agora.{Catalog, Orders}
  alias Agora.Accounts.Scope

  @doc """
  Creates a Stripe Checkout Session for a listing purchase and persists a
  pending Order. Returns `{:ok, checkout_url}` on success.
  """
  def create_checkout_session(%Scope{} = scope, listing) do
    params = %{
      payment_method_types: ["card"],
      mode: "payment",
      line_items: [
        %{
          price_data: %{
            currency: "usd",
            unit_amount: listing.price_cents,
            product_data: %{
              name: listing.title,
              description: listing.description
            }
          },
          quantity: 1
        }
      ],
      success_url: success_url(),
      cancel_url: cancel_url(listing.id),
      metadata: %{
        listing_id: to_string(listing.id),
        buyer_id: to_string(scope.user.id)
      }
    }

    with {:ok, session} <- Stripe.Checkout.Session.create(params),
         {:ok, _order} <-
           Orders.create_order(scope, %{
             listing_id: listing.id,
             amount_cents: listing.price_cents,
             stripe_session_id: session.id,
             status: "pending"
           }) do
      {:ok, session.url}
    end
  end

  @doc """
  Handles an incoming Stripe webhook event. Verifies the signature and
  dispatches to the appropriate handler.
  """
  def handle_webhook(raw_body, stripe_signature) do
    webhook_secret = Application.get_env(:stripity_stripe, :webhook_secret)

    case Stripe.Webhook.construct_event(raw_body, stripe_signature, webhook_secret) do
      {:ok, %{type: "checkout.session.completed", data: %{object: session}}} ->
        handle_checkout_completed(session)

      {:ok, _event} ->
        :ok

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp handle_checkout_completed(session) do
    with order when not is_nil(order) <- Orders.get_order_by_session!(session.id),
         listing <- Catalog.get_listing!(order.listing_id),
         {:ok, _} <- Orders.mark_paid(order),
         {:ok, _} <- Catalog.update_listing_status(listing, "sold") do
      :ok
    else
      nil -> {:error, :order_not_found}
      {:error, _} = err -> err
    end
  end

  defp success_url do
    base = AgoraWeb.Endpoint.url()
    "#{base}/my/orders?payment=success"
  end

  defp cancel_url(listing_id) do
    base = AgoraWeb.Endpoint.url()
    "#{base}/listings/#{listing_id}?payment=cancelled"
  end
end

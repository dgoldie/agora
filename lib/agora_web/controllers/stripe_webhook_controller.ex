defmodule AgoraWeb.StripeWebhookController do
  use AgoraWeb, :controller

  alias Agora.Payments

  def handle(conn, _params) do
    raw_body = conn.assigns[:raw_body] |> List.wrap() |> Enum.join()
    signature = get_req_header(conn, "stripe-signature") |> List.first()

    case Payments.handle_webhook(raw_body, signature) do
      :ok ->
        send_resp(conn, 200, "ok")

      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{error: inspect(reason)})
    end
  end
end

defmodule AgoraWeb.CacheBodyReader do
  @moduledoc false

  # Caches the raw request body in conn.assigns[:raw_body] so that
  # the Stripe webhook controller can verify the HMAC signature after
  # Plug.Parsers has already consumed the body stream.

  def read_body(conn, opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
    conn = update_in(conn.assigns[:raw_body], &[body | (&1 || [])])
    {:ok, body, conn}
  end
end

defmodule AgoraWeb.UserSessionHTML do
  use AgoraWeb, :html

  embed_templates "user_session_html/*"

  defp local_mail_adapter? do
    Application.get_env(:agora, Agora.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end

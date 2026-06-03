defmodule AgoraWeb.PageController do
  use AgoraWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

defmodule AgoraWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use AgoraWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="navbar sticky top-0 z-50 bg-base-100/90 backdrop-blur border-b border-base-200 px-4 sm:px-6 lg:px-8 shadow-sm">
      <div class="flex-1 gap-2">
        <.link navigate={~p"/"} class="flex items-center gap-2 group">
          <div class="w-8 h-8 rounded-lg bg-primary flex items-center justify-center text-primary-content font-black text-sm">A</div>
          <span class="font-bold text-lg tracking-tight hidden sm:block">Agora</span>
        </.link>
        <div class="divider divider-horizontal mx-1 hidden sm:flex" />
        <nav class="hidden sm:flex gap-1">
          <.link navigate={~p"/listings"} class="btn btn-ghost btn-sm rounded-full">
            <.icon name="hero-squares-2x2-micro" class="size-4" /> Browse
          </.link>
          <%= if @current_scope && @current_scope.user do %>
            <.link navigate={~p"/listings/new"} class="btn btn-ghost btn-sm rounded-full">
              <.icon name="hero-plus-circle-micro" class="size-4" /> Sell
            </.link>
          <% end %>
        </nav>
      </div>

      <div class="flex-none flex items-center gap-2">
        <.theme_toggle />
        <%= if @current_scope && @current_scope.user do %>
          <div class="dropdown dropdown-end">
            <div tabindex="0" role="button" class="btn btn-ghost btn-circle avatar placeholder">
              <div class="bg-primary text-primary-content rounded-full w-8 flex items-center justify-center font-bold text-sm">
                {String.first(@current_scope.user.display_name || @current_scope.user.email) |> String.upcase()}
              </div>
            </div>
            <ul tabindex="0" class="dropdown-content menu menu-sm bg-base-100 rounded-box z-50 mt-3 w-52 p-2 shadow-lg border border-base-200">
              <li class="menu-title text-xs truncate px-3 py-1">{@current_scope.user.email}</li>
              <li><.link navigate={~p"/my/listings"}><.icon name="hero-tag-micro" class="size-4" /> My Listings</.link></li>
              <li><.link navigate={~p"/my/orders"}><.icon name="hero-shopping-bag-micro" class="size-4" /> My Orders</.link></li>
              <li><.link navigate={~p"/users/settings"}><.icon name="hero-cog-6-tooth-micro" class="size-4" /> Settings</.link></li>
              <li class="border-t border-base-200 mt-1 pt-1">
                <.link href={~p"/users/log-out"} method="delete" class="text-error">
                  <.icon name="hero-arrow-right-on-rectangle-micro" class="size-4" /> Log out
                </.link>
              </li>
            </ul>
          </div>
        <% else %>
          <.link navigate={~p"/users/log-in"} class="btn btn-ghost btn-sm">Log in</.link>
          <.link navigate={~p"/users/register"} class="btn btn-primary btn-sm rounded-full">
            Get started
          </.link>
        <% end %>
      </div>
    </header>

    <main class="flex-1 px-4 py-8 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-7xl border-x border-base-200 px-4 sm:px-8 lg:px-12 rounded-b-xl">
        {render_slot(@inner_block)}
      </div>
    </main>

    <footer class="footer footer-center p-6 bg-base-200 text-base-content/60 text-sm border-t border-base-300 mt-auto">
      <p>© {Date.utc_today().year} Agora — Buy and Sell Anything</p>
    </footer>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end

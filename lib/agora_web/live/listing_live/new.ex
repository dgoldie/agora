defmodule AgoraWeb.ListingLive.New do
  use AgoraWeb, :live_view

  alias Agora.Catalog
  alias Agora.Catalog.Listing

  def mount(_params, _session, socket) do
    categories = Catalog.list_categories()
    changeset = Catalog.change_listing(%Listing{})

    {:ok,
     socket
     |> assign(:page_title, "New Listing")
     |> assign(:categories, categories)
     |> assign_form(changeset)}
  end

  def handle_event("validate", %{"listing" => params}, socket) do
    params = dollars_to_cents(params)

    changeset =
      %Listing{}
      |> Catalog.change_listing(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"listing" => params}, socket) do
    params = dollars_to_cents(params)

    case Catalog.create_listing(socket.assigns.current_scope, params) do
      {:ok, listing} ->
        {:noreply,
         socket
         |> put_flash(:info, "Listing created!")
         |> push_navigate(to: ~p"/listings/#{listing.id}")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto">
      <h1 class="text-2xl font-bold mb-6">Create a New Listing</h1>

      <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-4">
        <.input field={@form[:title]} label="Title" placeholder="What are you selling?" />
        <.input field={@form[:description]} type="textarea" label="Description" placeholder="Describe your item..." />

        <div class="grid grid-cols-2 gap-4">
          <.input
            field={@form[:price_cents]}
            label="Price ($)"
            type="number"
            name="listing[price_dollars]"
            value={cents_to_dollars(@form[:price_cents].value)}
            min="0.01"
            step="0.01"
            placeholder="0.00"
          />

          <.input
            field={@form[:category_id]}
            type="select"
            label="Category"
            options={[{"Select a category...", ""} | Enum.map(@categories, &{&1.name, &1.id})]}
          />
        </div>

        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          options={[{"Draft (not visible)", "draft"}, {"Active (visible to buyers)", "active"}]}
        />

        <div class="flex gap-3 pt-2">
          <button type="submit" class="btn btn-primary">Create Listing</button>
          <.link navigate={~p"/my/listings"} class="btn btn-ghost">Cancel</.link>
        </div>
      </.form>
    </div>
    """
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset, as: :listing))
  end

  defp dollars_to_cents(%{"price_dollars" => dollars} = params) do
    cents =
      case Float.parse(to_string(dollars)) do
        {val, _} -> round(val * 100)
        :error -> nil
      end

    Map.put(params, "price_cents", cents)
  end

  defp dollars_to_cents(params), do: params

  defp cents_to_dollars(nil), do: ""
  defp cents_to_dollars(cents) when is_integer(cents), do: :erlang.float_to_binary(cents / 100, decimals: 2)
  defp cents_to_dollars(_), do: ""
end

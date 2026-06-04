defmodule AgoraWeb.ListingLive.New do
  use AgoraWeb, :live_view

  alias Agora.Catalog
  alias Agora.Catalog.Listing

  @upload_dir "priv/static/uploads"

  def mount(_params, _session, socket) do
    categories = Catalog.list_categories()
    changeset = Catalog.change_listing(%Listing{})

    {:ok,
     socket
     |> assign(:page_title, "New Listing")
     |> assign(:categories, categories)
     |> assign_form(changeset)
     |> allow_upload(:image,
       accept: ~w(.jpg .jpeg .png .webp),
       max_entries: 1,
       max_file_size: 8_000_000
     )}
  end

  def handle_event("validate", %{"listing" => params}, socket) do
    params = dollars_to_cents(params)
    changeset = %Listing{} |> Catalog.change_listing(params) |> Map.put(:action, :validate)
    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  def handle_event("save", %{"listing" => params}, socket) do
    params = dollars_to_cents(params)

    image_url =
      consume_uploaded_entries(socket, :image, fn %{path: tmp_path}, entry ->
        ext = Path.extname(entry.client_name)
        filename = "#{System.unique_integer([:positive])}#{ext}"
        dest = Path.join([@upload_dir, filename])
        File.cp!(tmp_path, dest)
        {:ok, ~p"/uploads/#{filename}"}
      end)
      |> List.first()

    params = if image_url, do: Map.put(params, "image_url", image_url), else: params

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
    <div class="max-w-2xl mx-auto space-y-6">
      <div>
        <h1 class="text-3xl font-bold">Create a Listing</h1>
        <p class="text-base-content/50 mt-1">Fill in the details below to list your item for sale.</p>
      </div>

      <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-6">

        <%!-- Section: Basic info --%>
        <div class="card bg-base-100 border border-base-200 rounded-2xl">
          <div class="card-body gap-4">
            <h2 class="font-semibold text-base-content/70 uppercase text-xs tracking-wider">Basic Info</h2>
            <.input field={@form[:title]} label="Title" placeholder="What are you selling?" />
            <.input field={@form[:description]} type="textarea" label="Description" placeholder="Describe your item — condition, specs, why you're selling..." />
          </div>
        </div>

        <%!-- Section: Pricing & Category --%>
        <div class="card bg-base-100 border border-base-200 rounded-2xl">
          <div class="card-body gap-4">
            <h2 class="font-semibold text-base-content/70 uppercase text-xs tracking-wider">Pricing & Category</h2>
            <div class="grid grid-cols-2 gap-4">
              <div class="form-control">
                <label class="label"><span class="label-text">Price</span></label>
                <label class="input input-bordered flex items-center gap-2">
                  <span class="text-base-content/50 font-medium">$</span>
                  <input
                    type="number"
                    name="listing[price_dollars]"
                    value={cents_to_dollars(@form[:price_cents].value)}
                    min="0.01"
                    step="0.01"
                    placeholder="0.00"
                    class="grow"
                  />
                </label>
              </div>
              <.input
                field={@form[:category_id]}
                type="select"
                label="Category"
                options={[{"Select...", ""} | Enum.map(@categories, &{"#{&1.icon} #{&1.name}", &1.id})]}
              />
            </div>
            <.input
              field={@form[:status]}
              type="select"
              label="Visibility"
              options={[{"Draft — save but don't publish yet", "draft"}, {"Active — visible to buyers now", "active"}]}
            />
          </div>
        </div>

        <%!-- Section: Photo --%>
        <div class="card bg-base-100 border border-base-200 rounded-2xl">
          <div class="card-body gap-4">
            <h2 class="font-semibold text-base-content/70 uppercase text-xs tracking-wider">Photo (optional)</h2>
            <div
              class="border-2 border-dashed border-base-300 rounded-xl p-10 text-center hover:border-primary/50 hover:bg-primary/5 transition-colors cursor-pointer"
              phx-drop-target={@uploads.image.ref}
            >
              <.live_file_input upload={@uploads.image} class="hidden" />
              <div class="space-y-2">
                <div class="text-4xl">📷</div>
                <p class="font-medium text-sm">
                  Drop your photo here or
                  <label for={@uploads.image.ref} class="link link-primary cursor-pointer">browse files</label>
                </p>
                <p class="text-xs text-base-content/40">JPG, PNG, WEBP · max 8MB</p>
              </div>
            </div>

            <div :for={entry <- @uploads.image.entries} class="flex items-center gap-4 p-3 bg-base-200 rounded-xl">
              <.live_img_preview entry={entry} class="w-16 h-16 object-cover rounded-lg" />
              <div class="flex-1 min-w-0">
                <p class="text-sm font-medium truncate">{entry.client_name}</p>
                <progress class="progress progress-primary w-full mt-1" value={entry.progress} max="100" />
              </div>
              <button type="button" phx-click="cancel_upload" phx-value-ref={entry.ref} class="btn btn-circle btn-ghost btn-sm">
                <.icon name="hero-x-mark-micro" class="size-4" />
              </button>
            </div>

            <p :for={err <- upload_errors(@uploads.image)} class="text-error text-sm">
              {upload_error_to_string(err)}
            </p>
          </div>
        </div>

        <%!-- Actions --%>
        <div class="flex gap-3">
          <button type="submit" class="btn btn-primary btn-lg rounded-full flex-1 shadow-md">
            <.icon name="hero-check-micro" class="size-5" /> Create Listing
          </button>
          <.cta_link navigate={~p"/my/listings"} variant={:back}>Cancel</.cta_link>
        </div>
      </.form>
    </div>
    """
  end

  defp assign_form(socket, changeset), do: assign(socket, :form, to_form(changeset, as: :listing))

  defp dollars_to_cents(%{"price_dollars" => dollars} = params) do
    cents = case Float.parse(to_string(dollars)) do
      {val, _} -> round(val * 100)
      :error -> nil
    end
    Map.put(params, "price_cents", cents)
  end

  defp dollars_to_cents(params), do: params

  defp cents_to_dollars(nil), do: ""
  defp cents_to_dollars(cents) when is_integer(cents), do: :erlang.float_to_binary(cents / 100, decimals: 2)
  defp cents_to_dollars(_), do: ""

  defp upload_error_to_string(:too_large), do: "File too large (max 8MB)"
  defp upload_error_to_string(:not_accepted), do: "Unsupported file type"
  defp upload_error_to_string(:too_many_files), do: "Only one image allowed"
  defp upload_error_to_string(_), do: "Upload error"
end

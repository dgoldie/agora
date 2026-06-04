alias Agora.Repo
alias Agora.Accounts
alias Agora.Catalog.{Category, Listing}

# ---------------------------------------------------------------------------
# Categories
# ---------------------------------------------------------------------------

categories =
  [
    %{name: "Electronics", slug: "electronics", icon: "💻"},
    %{name: "Clothing", slug: "clothing", icon: "👕"},
    %{name: "Books", slug: "books", icon: "📚"},
    %{name: "Home & Garden", slug: "home-garden", icon: "🏡"},
    %{name: "Sports & Outdoors", slug: "sports-outdoors", icon: "⚽"},
    %{name: "Toys & Games", slug: "toys-games", icon: "🎮"},
    %{name: "Vehicles", slug: "vehicles", icon: "🚗"},
    %{name: "Other", slug: "other", icon: "📦"}
  ]
  |> Enum.map(fn attrs ->
    case Repo.get_by(Category, slug: attrs.slug) do
      nil -> Repo.insert!(%Category{name: attrs.name, slug: attrs.slug, icon: attrs.icon})
      existing -> existing
    end
  end)

IO.puts("Seeded #{length(categories)} categories.")

# ---------------------------------------------------------------------------
# Demo seller account
# ---------------------------------------------------------------------------

seller =
  case Accounts.get_user_by_email("seller@example.com") do
    nil ->
      {:ok, user} =
        Accounts.register_user(%{
          email: "seller@example.com",
          password: "password123456"
        })

      Repo.update!(Ecto.Changeset.change(user, display_name: "Demo Seller", bio: "I sell great stuff!"))

    existing ->
      existing
  end

# ---------------------------------------------------------------------------
# Sample listings
# ---------------------------------------------------------------------------

electronics = Enum.find(categories, &(&1.slug == "electronics"))
books = Enum.find(categories, &(&1.slug == "books"))
clothing = Enum.find(categories, &(&1.slug == "clothing"))
home = Enum.find(categories, &(&1.slug == "home-garden"))
sports = Enum.find(categories, &(&1.slug == "sports-outdoors"))

sample_listings = [
  %{
    title: "MacBook Pro 14\" M3 — Like New",
    description: "Used for 3 months, in perfect condition. Comes with original charger and box. 16GB RAM, 512GB SSD.",
    price_cents: 149900,
    status: "active",
    category_id: electronics.id,
    seller_id: seller.id
  },
  %{
    title: "Sony WH-1000XM5 Headphones",
    description: "Excellent noise cancelling. Barely used, includes case and all cables.",
    price_cents: 22000,
    status: "active",
    category_id: electronics.id,
    seller_id: seller.id
  },
  %{
    title: "iPhone 15 Pro — 256GB Natural Titanium",
    description: "Unlocked, no scratches. Bought outright, selling due to upgrade.",
    price_cents: 89900,
    status: "active",
    category_id: electronics.id,
    seller_id: seller.id
  },
  %{
    title: "Elixir in Action, 3rd Edition",
    description: "Excellent book for learning Elixir and OTP. Paperback, very good condition.",
    price_cents: 2500,
    status: "active",
    category_id: books.id,
    seller_id: seller.id
  },
  %{
    title: "Programming Phoenix LiveView",
    description: "The definitive guide to Phoenix LiveView by Bruce Tate and Sophie DeBenedetto. Like new.",
    price_cents: 3500,
    status: "active",
    category_id: books.id,
    seller_id: seller.id
  },
  %{
    title: "Patagonia Nano Puff Jacket — Medium",
    description: "Classic navy blue. Worn a handful of times, no damage. Warm and lightweight.",
    price_cents: 8500,
    status: "active",
    category_id: clothing.id,
    seller_id: seller.id
  },
  %{
    title: "Levi's 501 Original Jeans — W32 L32",
    description: "Classic straight fit, dark wash. Worn twice. Still stiff, great condition.",
    price_cents: 4500,
    status: "active",
    category_id: clothing.id,
    seller_id: seller.id
  },
  %{
    title: "Dyson V15 Detect Cordless Vacuum",
    description: "Powerful laser dust detection. Used for 6 months, all attachments included.",
    price_cents: 37500,
    status: "active",
    category_id: home.id,
    seller_id: seller.id
  },
  %{
    title: "Weber Spirit II E-310 Gas Grill",
    description: "3-burner propane grill, great for outdoor cooking. Lightly used, cleaned before listing.",
    price_cents: 28000,
    status: "active",
    category_id: home.id,
    seller_id: seller.id
  },
  %{
    title: "Trek FX 3 Disc Hybrid Bike — 54cm",
    description: "2022 model, hydraulic disc brakes, only 200 miles. Includes lights and a lock.",
    price_cents: 65000,
    status: "active",
    category_id: sports.id,
    seller_id: seller.id
  },
  %{
    title: "Yeti Tundra 45 Cooler",
    description: "Legendary insulation. White, used on two camping trips. Spotless inside.",
    price_cents: 19500,
    status: "active",
    category_id: sports.id,
    seller_id: seller.id
  }
]

import Ecto.Query
existing_titles = Repo.all(from(l in Listing, select: l.title)) |> MapSet.new()

inserted =
  sample_listings
  |> Enum.reject(&MapSet.member?(existing_titles, &1.title))
  |> Enum.map(fn attrs ->
    Repo.insert!(%Listing{
      title: attrs.title,
      description: attrs.description,
      price_cents: attrs.price_cents,
      status: attrs.status,
      category_id: attrs.category_id,
      seller_id: attrs.seller_id
    })
  end)

IO.puts("Seeded #{length(inserted)} listings.")
IO.puts("\nDemo seller: seller@example.com / password123456")

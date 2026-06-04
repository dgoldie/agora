# Agora — Generic Marketplace Build Plan

**Stack**: Elixir 1.18 / Phoenix 1.8.7 / LiveView / PostgreSQL / Stripe Checkout

---

## Phase 1 — Foundation

- [x] `mix phx.new agora --database postgres --live`
- [x] `mix deps.get` + `mix ecto.create`

---

## Phase 2 — Auth

- [x] `mix phx.gen.auth Accounts User users`
- [x] `mix ecto.migrate`
- [x] Add `:display_name` and `:bio` fields to users (seller profile basics)

---

## Phase 3 — Core Domain Schemas

| Schema | Key fields |
|---|---|
| `Catalog.Category` | `name`, `slug`, `icon` | ✅ |
| `Catalog.Listing` | `title`, `description`, `price_cents`, `status` (`draft/active/sold`), `category_id`, `seller_id` | ✅ |
| `Orders.Order` | `listing_id`, `buyer_id`, `status` (`pending/paid/cancelled`), `stripe_session_id`, `amount_cents` | ✅ |

---

## Phase 4 — LiveView Pages

| Route | LiveView | Purpose |
|---|---|---|
| `/` | `HomeLive` | Featured listings, category nav | ✅ |
| `/listings` | `ListingLive.Index` | Browse + filter by category/search | ✅ |
| `/listings/:id` | `ListingLive.Show` | Detail + Buy Now button | ✅ |
| `/listings/new` | `ListingLive.New` | Seller creates listing | ✅ |
| `/my/listings` | `SellerLive.Dashboard` | Seller manages their listings | ✅ |
| `/my/orders` | `BuyerLive.Orders` | Buyer sees order history | ✅ |

---

## Phase 5 — Stripe Checkout

- [x] Add `stripity_stripe` hex dep
- [x] On "Buy Now" → create `Checkout.Session`, redirect to Stripe
- [x] Webhook handler for `checkout.session.completed` → mark order `paid`, mark listing `sold`

---

## Phase 6 — Polish

- [x] Seed categories + sample listings
- [x] Image upload (LiveView + local storage or S3)
- [x] Basic reviews (1–5 stars, text)

---

## Phase 7 — DaisyUI Design Overhaul

### Global
- [x] Sticky navbar: logo, avatar dropdown, theme toggle, mobile-friendly
- [x] Footer: branding + year
- [x] `min-h-screen flex flex-col` body for footer anchoring

### Home (`HomeLive`)
- [x] Hero section: gradient background, bold headline, CTA buttons with icons
- [x] Category grid: icon + label cards with hover effects
- [x] Listing grid: `card` with shadow, image/placeholder, price
- [x] How it works: 3-step explainer section

### Browse (`ListingLive.Index`)
- [x] Filter bar: category pill strip + search join input
- [x] Listing cards: uniform image square, price, category badge
- [x] Active filter banner with clear button
- [x] Empty state: illustrated with clear-filters CTA

### Listing Detail (`ListingLive.Show`)
- [x] Two-column layout: image left, details right
- [x] Price + Buy Now: prominent CTA with `btn-primary btn-lg rounded-full`
- [x] Seller card: avatar initial, name, bio
- [x] Reviews: DaisyUI `rating` input, star display, avatar initials, review cards

### Create Listing (`ListingLive.New`)
- [x] Stepped card layout with section headers
- [x] Upload zone: styled drop area with icon + progress bar
- [x] Price input: dollar prefix label inside input

### Seller Dashboard (`SellerLive.Dashboard`)
- [x] Stats row: total, active, draft, sold with color-coded cards
- [x] Thumbnail in table rows
- [x] Status badges: color-coded `badge-success/warning/error`

### Buyer Orders (`BuyerLive.Orders`)
- [x] Order cards with colored left stripe by status
- [x] Listing thumbnail in each order card
- [x] Empty state with browse CTA

---

## Phase 8 — Sexy "View All" Links

Replace plain `link` text with styled animated CTAs throughout the app:

- [x] **HomeLive** — "Browse listings" + "See all" → pill buttons with arrow icon + hover slide animation
- [x] **ListingLive.Index** — "Clear filters" → ghost pill with × icon; "New Listing" → primary pill
- [x] **ListingLive.Show** — "Back to listings" → animated back arrow; "Manage your listings" + "Log in to buy" → cta_link
- [x] **SellerLive.Dashboard** — "New Listing" + "Create a listing" → primary pill CTAs
- [x] **BuyerLive.Orders** — "Browse listings" empty-state → primary pill CTA
- [x] **ListingLive.New** — "Cancel" → back variant
- [x] **Global** — `<.cta_link>` component in `core_components.ex`, variants: `:primary`, `:ghost`, `:arrow`, `:back` — sliding arrow animation via Tailwind group-hover
- [ ] **Layout** — Add subtle left and right border lines to the main content area to frame the page on wide screens

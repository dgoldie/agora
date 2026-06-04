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
- [ ] Pick a DaisyUI theme (e.g. `night`, `cupcake`, or custom) set in `root.html.heex`
- [ ] Navbar: logo wordmark, sticky top bar, mobile hamburger menu
- [ ] Footer: links, branding, social icons

### Home (`HomeLive`)
- [ ] Hero section: gradient background, bold headline, CTA buttons with icons
- [ ] Category pills: styled `badge` row with hover effects
- [ ] Listing grid: `card` with shadow, image placeholder, price badge overlay

### Browse (`ListingLive.Index`)
- [ ] Filter bar: sticky sidebar or top filter strip (category + search)
- [ ] Listing cards: uniform height, image top, price + category badge
- [ ] Empty state: illustrated empty message

### Listing Detail (`ListingLive.Show`)
- [ ] Image hero: full-width rounded image or placeholder
- [ ] Price + Buy Now: prominent CTA with `btn-primary btn-lg`
- [ ] Seller card: avatar initial, name, member since
- [ ] Reviews: star display with filled/empty icons, review cards with avatars

### Create Listing (`ListingLive.New`)
- [ ] Stepped card layout with section headers
- [ ] Upload zone: styled drop area with icon
- [ ] Price input: dollar prefix inside input

### Seller Dashboard (`SellerLive.Dashboard`)
- [ ] Stats row: total listings, active, draft, sold counts
- [ ] Status badges: color-coded `badge-success/warning/error`

### Buyer Orders (`BuyerLive.Orders`)
- [ ] Order cards with status timeline indicator
- [ ] Empty state with browse CTA

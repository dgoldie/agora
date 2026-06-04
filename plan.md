# Agora — Generic Marketplace Build Plan

**Stack**: Elixir 1.18 / Phoenix 1.8.7 / LiveView / PostgreSQL / Stripe Checkout

---

## Phase 1 — Foundation

- [x] `mix phx.new agora --database postgres --live`
- [x] `mix deps.get` + `mix ecto.create`

---

## Phase 2 — Auth

- [ ] `mix phx.gen.auth Accounts User users`
- [ ] `mix ecto.migrate`
- [ ] Add `:display_name` and `:bio` fields to users (seller profile basics)

---

## Phase 3 — Core Domain Schemas

| Schema | Key fields |
|---|---|
| `Catalog.Category` | `name`, `slug`, `icon` |
| `Catalog.Listing` | `title`, `description`, `price_cents`, `status` (`draft/active/sold`), `category_id`, `seller_id` |
| `Orders.Order` | `listing_id`, `buyer_id`, `status` (`pending/paid/cancelled`), `stripe_session_id`, `amount_cents` |

---

## Phase 4 — LiveView Pages

| Route | LiveView | Purpose |
|---|---|---|
| `/` | `HomeLive` | Featured listings, category nav |
| `/listings` | `ListingLive.Index` | Browse + filter by category/search |
| `/listings/:id` | `ListingLive.Show` | Detail + Buy Now button |
| `/listings/new` | `ListingLive.New` | Seller creates listing |
| `/my/listings` | `SellerLive.Dashboard` | Seller manages their listings |
| `/my/orders` | `BuyerLive.Orders` | Buyer sees order history |

---

## Phase 5 — Stripe Checkout

- [ ] Add `stripity_stripe` hex dep
- [ ] On "Buy Now" → create `Checkout.Session`, redirect to Stripe
- [ ] Webhook handler for `checkout.session.completed` → mark order `paid`, mark listing `sold`

---

## Phase 6 — Polish

- [ ] Seed categories + sample listings
- [ ] Image upload (LiveView + local storage or S3)
- [ ] Basic reviews (1–5 stars, text)

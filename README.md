# Recurring Items Tracker

A mobile-first household tracker for recurring maintenance/replacement items
(CPAP supplies, home upkeep, car, personal). Rebuilt from the original Google
Sheet + Apps Script version onto a fully self-contained **Cloudflare** stack.

## Architecture

| Layer     | Original (Gemini)              | This rebuild                          |
|-----------|--------------------------------|---------------------------------------|
| Frontend  | `index.html` (HtmlService)     | `public/index.html` (static, `fetch`) |
| Backend   | Apps Script `doGet`/`doPost`   | Cloudflare Worker `src/index.js`      |
| Database  | Google Sheet                   | Cloudflare **D1** (SQLite)            |
| Hosting   | Apps Script web-app URL        | Cloudflare Workers + static assets    |

The Worker serves the static frontend via the `ASSETS` binding and exposes a
small JSON API backed by D1:

- `GET    /api/items` — list all items
- `POST   /api/items` — create an item
- `PATCH  /api/items/:id` — update one field `{ field, value }`
- `DELETE /api/items/:id` — delete an item

Editing any field re-syncs and recomputes the projected **Next Due Date** across
a 36-month window (2026–2028), preserving the original scheduling logic.

## ⚠️ Google Drive note (read first)

This folder is the **canonical source**, kept on Google Drive for backup/sync.
**Do not run `npm` or `wrangler` from here** — Google Drive File Stream serves
`node_modules` files as virtual placeholders, which corrupts them and breaks the
toolchain (`ERR_INVALID_PACKAGE_CONFIG`). Also, the `&` in the parent path
("EKG & KKG") breaks npm's Windows shell shims.

Instead:
- **Deploy** happens automatically via **GitHub → Cloudflare** (see below). You
  never need to run tooling locally for normal updates.
- **If you ever need to build/run locally**, `git clone` the GitHub repo to a
  plain local path (e.g. `C:\dev\household-tracker`) and run commands there.

## First-time setup (from a LOCAL clone, not this Drive folder)

Prereqs: Node 18+, a Cloudflare account (`wrangler login` or a `CLOUDFLARE_API_TOKEN`).

```bash
npm install

# 1. Create the D1 database, then paste the returned database_id into wrangler.jsonc
npx wrangler d1 create recurring_tracker

# 2. Seed the schema + 31 items
npm run db:remote      # production D1
npm run db:local       # local dev copy

# 3. Deploy
npm run deploy
```

## Local development

```bash
npm run db:local       # seed the local D1 once
npm run dev            # http://localhost:8787
```

## Continuous deployment (GitHub → Cloudflare)

Connect this repo in the Cloudflare dashboard under **Workers & Pages → Create →
Workers → Connect to Git**. Every push to `main` builds and deploys automatically.
Build command: `npx wrangler deploy`.

## Data model (`items` table)

`category, name, number, interval, start_month, start_year, last_completed,
unit_cost, notes, sort_order`

`interval` ∈ {Years, Months, Quarters, Weeks, TBD}. Annual cost is derived
(`number × unit_cost`).

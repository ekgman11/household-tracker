/**
 * Recurring Items Tracker — Cloudflare Worker
 *
 * Serves the static frontend (via the ASSETS binding) and a small JSON API
 * backed by D1. This replaces the old Google Apps Script backend
 * (doGet / getTrackerData / updateRowValue).
 *
 * Routes:
 *   GET    /api/items          -> list all items
 *   POST   /api/items          -> create an item (JSON body)
 *   PATCH  /api/items/:id       -> update one field { field, value }
 *   DELETE /api/items/:id       -> delete an item
 *   *                           -> static asset (index.html)
 */

// Column whitelist so PATCH can only touch known fields.
const EDITABLE = {
  category: "category",
  name: "name",
  number: "number",
  interval: "interval",
  startMonth: "start_month",
  startYear: "start_year",
  lastCompleted: "last_completed",
  unitCost: "unit_cost",
  notes: "notes",
};

const json = (data, status = 200) =>
  new Response(JSON.stringify(data), {
    status,
    headers: { "content-type": "application/json; charset=utf-8" },
  });

// Map a DB row to the shape the frontend expects.
function toItem(row) {
  return {
    id: row.id,
    category: row.category,
    name: row.name,
    number: row.number,
    interval: row.interval,
    startMonth: row.start_month,
    startYear: String(row.start_year),
    lastCompleted: row.last_completed || "",
    unitCost: row.unit_cost,
    notes: row.notes || "",
  };
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const { pathname } = url;

    if (!pathname.startsWith("/api/")) {
      // Non-API requests are served by the static assets binding.
      return env.ASSETS.fetch(request);
    }

    try {
      // /api/items
      if (pathname === "/api/items") {
        if (request.method === "GET") {
          const { results } = await env.DB.prepare(
            "SELECT * FROM items ORDER BY sort_order, id"
          ).all();
          return json(results.map(toItem));
        }
        if (request.method === "POST") {
          const b = await request.json();
          const { meta } = await env.DB.prepare(
            `INSERT INTO items
               (category, name, number, interval, start_month, start_year, last_completed, unit_cost, notes, sort_order)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
          )
            .bind(
              b.category ?? "Home",
              b.name ?? "New item",
              Number(b.number) || 0,
              b.interval || "TBD",
              b.startMonth || "TBD",
              String(b.startYear || "TBD"),
              b.lastCompleted || "",
              Number(b.unitCost) || 0,
              b.notes || "",
              Number(b.sortOrder) || 999
            )
            .run();
          const row = await env.DB.prepare("SELECT * FROM items WHERE id = ?")
            .bind(meta.last_row_id)
            .first();
          return json(toItem(row), 201);
        }
        return json({ error: "Method not allowed" }, 405);
      }

      // /api/items/:id
      const m = pathname.match(/^\/api\/items\/(\d+)$/);
      if (m) {
        const id = Number(m[1]);

        if (request.method === "PATCH") {
          const { field, value } = await request.json();
          const col = EDITABLE[field];
          if (!col) return json({ error: `Unknown field: ${field}` }, 400);
          await env.DB.prepare(`UPDATE items SET ${col} = ? WHERE id = ?`)
            .bind(value, id)
            .run();
          const row = await env.DB.prepare("SELECT * FROM items WHERE id = ?")
            .bind(id)
            .first();
          return row ? json(toItem(row)) : json({ error: "Not found" }, 404);
        }

        if (request.method === "DELETE") {
          await env.DB.prepare("DELETE FROM items WHERE id = ?").bind(id).run();
          return json({ ok: true });
        }
        return json({ error: "Method not allowed" }, 405);
      }

      return json({ error: "Not found" }, 404);
    } catch (err) {
      return json({ error: String(err && err.message ? err.message : err) }, 500);
    }
  },
};

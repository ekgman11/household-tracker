-- Recurring Items Tracker — D1 schema + seed data
-- Rebuilt from the Google Apps Script "Recurring Tracker 2026-2028" (createInteractiveTrackerV5).
-- Run:  wrangler d1 execute recurring_tracker --file=./schema.sql --remote

DROP TABLE IF EXISTS items;

CREATE TABLE items (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  category       TEXT    NOT NULL,
  name           TEXT    NOT NULL,
  number         INTEGER NOT NULL DEFAULT 0,      -- occurrences within the interval window
  interval       TEXT    NOT NULL DEFAULT 'TBD',  -- Years | Months | Quarters | Weeks | TBD
  start_month    TEXT    NOT NULL DEFAULT 'TBD',  -- January..December | TBD
  start_year     TEXT    NOT NULL DEFAULT 'TBD',  -- 2026 | 2027 | 2028 | TBD
  last_completed TEXT    NOT NULL DEFAULT '',     -- yyyy-mm-dd or ''
  unit_cost      REAL    NOT NULL DEFAULT 0,
  notes          TEXT    NOT NULL DEFAULT '',
  sort_order     INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_items_category ON items(category);

INSERT INTO items (category, name, number, interval, start_month, start_year, last_completed, unit_cost, notes, sort_order) VALUES
  ('CPAP',     'CPAP Machine Rental',                  10, 'Months',   'January',  '2026', '',           73.18, 'Jan-Oct',                    1),
  ('CPAP',     'Nasal Interface',                       2, 'Months',   'February', '2026', '',           88.66, 'Bi-annual replacement',      2),
  ('CPAP',     'Tubing',                                4, 'Quarters', 'February', '2026', '',           31.87, 'Quarterly alignment',        3),
  ('CPAP',     'Nasal Cushion',                        12, 'Months',   'January',  '2026', '',           30.40, 'Standard replacement',       4),
  ('CPAP',     'Water Basin',                           2, 'Months',   'February', '2026', '',           22.38, 'Bi-annual replacement',      5),
  ('CPAP',     'Headgear',                              2, 'Months',   'February', '2026', '',           27.22, 'Bi-annual replacement',      6),
  ('CPAP',     'Filter',                               12, 'Months',   'January',  '2026', '',            7.38, 'Standard replacement',       7),
  ('Home',     'HVAC Filter',                           4, 'Quarters', 'June',     '2026', '',           38.99, 'Quarterly swap',             8),
  ('Home',     'Fridge Water Filter',                   2, 'Months',   'June',     '2026', '',           54.99, 'Semi-annual filter swap',    9),
  ('Home',     'Fridge Air Filter',                     1, 'Years',    'November', '2026', '',           15.99, 'Once per year',             10),
  ('Home',     'Exterminator Spray',                    3, 'Months',   'April',    '2026', '',            0,    'Targeted barrier treatment',11),
  ('Home',     'HVAC Coil Cleaning',                    1, 'Years',    'April',    '2026', '',            0,    'Pre-summer cleanup',        12),
  ('Home',     'Grill Deep Clean',                      1, 'Years',    'June',     '2026', '',           25,    'DIY deep cleaning',         13),
  ('Home',     'Nut Grass Weed Killer',                 2, 'Months',   'April',    '2026', '',            0,    'Seasonal yard care',        14),
  ('Home',     'Clean PC with Compressed Air',          3, 'Months',   'June',     '2026', '2026-06-07',  0,    'Sunday task iteration',     15),
  ('Home',     'Fridge coil',                           0, 'TBD',      'TBD',      'TBD',  '',            0,    'Pending',                   16),
  ('Home',     'Dryer vent',                            0, 'TBD',      'TBD',      'TBD',  '',            0,    'Pending',                   17),
  ('Home',     'Dishwasher filter clean',               0, 'TBD',      'TBD',      'TBD',  '',            0,    'Pending',                   18),
  ('Home',     'Weather stripping',                     0, 'TBD',      'TBD',      'TBD',  '',            0,    'Pending',                   19),
  ('Home',     'Water heater sediment',                 0, 'TBD',      'TBD',      'TBD',  '',            0,    'Pending',                   20),
  ('Home',     'Clean bathroom grout',                  0, 'TBD',      'TBD',      'TBD',  '',            0,    'Pending',                   21),
  ('Home',     'Dust HVAC covers',                      0, 'TBD',      'TBD',      'TBD',  '',            0,    'Pending',                   22),
  ('Home',     'Furnace filters',                       0, 'TBD',      'TBD',      'TBD',  '',            0,    'Pending',                   23),
  ('Home',     'Smoke detector batteries',              0, 'TBD',      'TBD',      'TBD',  '',            0,    'Pending',                   24),
  ('Home',     'Caulk sinks, showers, tubs',            0, 'TBD',      'TBD',      'TBD',  '',            0,    'Pending',                   25),
  ('Home',     'Snake drains',                          0, 'TBD',      'TBD',      'TBD',  '',            0,    'Pending',                   26),
  ('Home',     'Lubricate sliding door (clean trough)', 0, 'TBD',      'TBD',      'TBD',  '',            0,    'Pending',                   27),
  ('Home',     'Clean shower heads',                    0, 'TBD',      'TBD',      'TBD',  '',            0,    'Pending',                   28),
  ('Home',     'Gutters',                               0, 'TBD',      'TBD',      'TBD',  '',            0,    'Pending',                   29),
  ('Personal', 'Bong Cleaning',                        12, 'Months',   'January',  '2026', '',            5.00, 'Isopropyl + Salt',          30),
  ('Car',      'Cabin Air Filter',                      1, 'Years',    'January',  '2026', '',            0,    'Proxy marker',              31),
  ('Home',     'Washing machine filter',                0, 'TBD',      'TBD',      'TBD',  '',            0,    'Pending',                   32);

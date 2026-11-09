# RIFFS – Flutter + Supabase e-commerce

CS Elective 2 · Supabase-Flutter Activity (branch `backend-filter-pagination`)

The shop's products live in a Supabase (PostgreSQL) `products` table. The app reads,
filters, paginates, updates and deletes them with the `supabase_flutter` client, and
keeps the shop state in a `ProductProvider` (Provider / ChangeNotifier).

## Features in this branch

- **Price filter** – a price range slider on the home screen. Releasing the slider runs
  `.gte('price', min).lte('price', max)` on Supabase.
- **Pagination** – 6 products per page using `.range(from, to)` with
  `.count(CountOption.exact)` for the total, with previous / page number / next buttons.
- **Category filter** – `.eq('category', ...)`, combined with the price filter.
- **Update / delete** – the ⋮ menu on a product page edits the name and price
  (`.update(...).eq('id', id)`) or deletes the product (`.delete().eq('id', id)`).

Every query follows the order filter → `.order()` → `.range()`.

## Setup

1. Create a project at [supabase.com](https://supabase.com).
2. Open **SQL Editor → New query**, paste `supabase/products_schema.sql` and run it.
   It creates the `products` table, turns on Row Level Security with SELECT, INSERT,
   UPDATE and DELETE policies, and adds the 9 starter products.
3. Copy the **Project URL** and **anon / publishable key** from
   **Project Settings → API** into `supabaseUrl` and `supabasePublishableKey` in
   `lib/main.dart`. Never use the `service_role` key in the app.
4. Run:

   ```bash
   flutter pub get
   flutter run
   ```

## Project structure

| Path | Purpose |
| --- | --- |
| `lib/main.dart` | `Supabase.initialize(...)` and the global `supabase` client |
| `lib/services/product_service.dart` | All Supabase queries |
| `lib/providers/product_provider.dart` | Page, filters, loading and error state |
| `lib/widgets/home/price_range_filter.dart` | Price slider |
| `lib/widgets/product/pagination_bar.dart` | Page controls |
| `supabase/products_schema.sql` | Table, RLS policies and seed data |

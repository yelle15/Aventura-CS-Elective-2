# RIFFS – Flutter + Supabase e-commerce

CS Elective 2 · Supabase-Auth Activity (branch `backend-auth`)

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

## Authentication (branch `backend-auth`)

The shop is behind a sign-in screen backed by Supabase Auth.

- **Email and password** – `supabase.auth.signUp(...)` and
  `supabase.auth.signInWithPassword(...)`.
- **GitHub (third-party provider)** – `supabase.auth.signInWithOAuth(OAuthProvider.github)`.
- **Sign out** – the account menu in the app bar calls `supabase.auth.signOut()`.

`AuthProvider` listens to `supabase.auth.onAuthStateChange`, and the router redirects
to `/login` whenever there is no session.

### Auth setup

1. On GitHub, open **Settings → Developer settings → OAuth Apps → New OAuth App**.
   - Homepage URL: `http://localhost:3000`
   - Authorization callback URL: `https://<project-ref>.supabase.co/auth/v1/callback`
2. In Supabase, open **Authentication → Sign In / Providers → GitHub**, enable it and
   paste the Client ID and Client Secret from GitHub.
3. In **Authentication → URL Configuration**, set the Site URL to
   `http://localhost:3000` and add `http://localhost:3000/**` to the Redirect URLs.
4. Run the app on the same port:

   ```bash
   flutter run -d chrome --web-port 3000
   ```

5. Optional: run `supabase/auth_policies.sql` so only signed-in users can add, edit or
   delete products.

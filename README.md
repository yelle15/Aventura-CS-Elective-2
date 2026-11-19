# RIFFS – Flutter E-Commerce (Final Exam)

CS Elective 2 · Final Exam Project (branch `final-exam`)

A guitar and bass shop with two roles. **Admins** manage products, categories and
orders. **Customers** browse, filter, build a cart, check out and see their order
history. Every new account starts as a customer.

| Area | Used |
| --- | --- |
| State management | Riverpod 3 (`Notifier`, `FutureProvider`, `StreamProvider`) |
| Backend | Supabase Auth, Postgres, Row Level Security |
| Sign-in | Email and password, and Google |
| Images | Supabase Storage bucket `product-images` |

## Architecture

Screens call providers, providers call services, and only services talk to Supabase.

```
lib/
  core/        AppException (permission-denied, network and database errors), formatters
  models/      Product, ProductCategory, UserProfile, CartItem, Order, OrderItem
  services/    auth, profile, category, product, storage, order  ← only code that uses Supabase
  providers/   Riverpod providers and notifiers, plus the router and its auth gate
  screens/     auth/, customer/, admin/
  widgets/     shared UI (product card, filters, pagination, state views, navigation)
  theme/       app theme
supabase/
  final_exam_setup.sql   tables, functions, trigger, RLS, storage and seed data
```

## Security

The app hides admin buttons from customers, but that is only the interface. The real
rules are in the database:

- **RLS is enabled on every table**, and every policy is limited to signed-in users,
  so signed-out requests get nothing.
- `is_admin()` is `security definer`, so policies on `profiles` can call it without
  infinite recursion.
- Customers can update only their own `firstname` and `lastname`. `role_id` is not
  granted, so nobody can promote themselves.
- Orders and order items have no insert permission at all. The only way to create
  one is `place_order(items)`, which:
  - reads each product's **price, name and stock from the database** (the app only
    sends product ids and quantities),
  - locks those rows (`for update`) so two checkouts cannot oversell,
  - saves the order and all its items, reduces stock, and sets the status to `done`
    in **one transaction**. If any item fails, nothing is saved,
  - stores a snapshot of the product name and unit price on each order item.
- Storage uploads, updates and deletes are allowed only for admins.

## Setup

1. Create a **new** Supabase project for the exam, so the earlier activity branches
   keep working on their own project.
2. In **SQL Editor**, run `supabase/final_exam_setup.sql`.
3. Put the project URL and publishable key in `lib/main.dart`.
4. **Google sign-in**
   - In Google Cloud Console, create an OAuth client ID of type *Web application*.
   - Authorized JavaScript origin: `http://localhost:3000`
   - Authorized redirect URI: `https://<project-ref>.supabase.co/auth/v1/callback`
   - In Supabase, open **Authentication → Sign In / Providers → Google**, enable it and
     paste the client ID and secret.
5. In **Authentication → URL Configuration**, set the Site URL to
   `http://localhost:3000` and add `http://localhost:3000/**` to the Redirect URLs.
6. Run the app:

   ```bash
   flutter pub get
   flutter run -d chrome --web-port 3000
   ```

7. Sign up, then make that account an admin in the SQL Editor:

   ```sql
   update public.profiles
      set role_id = (select id from public.roles where role = 'admin')
    where email = 'you@example.com';
   ```

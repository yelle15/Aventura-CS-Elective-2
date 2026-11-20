drop trigger if exists on_auth_user_created on auth.users;
drop table if exists public.order_items cascade;
drop table if exists public.orders cascade;
drop table if exists public.products cascade;
drop table if exists public.categories cascade;
drop table if exists public.profiles cascade;
drop table if exists public.roles cascade;

create table public.roles (
  id          bigint generated always as identity primary key,
  role        varchar     not null unique,
  created_at  timestamptz not null default now(),
  encoded_by  uuid        references auth.users (id) on delete set null
);

create table public.profiles (
  id          uuid        primary key references auth.users (id) on delete cascade,
  created_at  timestamptz not null default now(),
  email       text,
  firstname   text,
  lastname    text,
  role_id     bigint      not null references public.roles (id)
);

create table public.categories (
  id          bigint generated always as identity primary key,
  created_at  timestamptz not null default now(),
  name        text        not null unique check (length(trim(name)) > 0)
);

create table public.products (
  id           bigint generated always as identity primary key,
  created_at   timestamptz   not null default now(),
  name         text          not null check (length(trim(name)) > 0),
  description  text          not null default '',
  price        numeric(12,2) not null check (price >= 0),
  stock        integer       not null default 0 check (stock >= 0),
  image_url    text          not null check (length(trim(image_url)) > 0),
  category_id  bigint        not null references public.categories (id) on delete restrict
);

create table public.orders (
  id          bigint generated always as identity primary key,
  created_at  timestamptz   not null default now(),
  user_id     uuid          not null references public.profiles (id) on delete cascade,
  status      text          not null default 'pending'
                            check (status in ('pending', 'done', 'shipped', 'cancelled')),
  total       numeric(12,2) not null default 0 check (total >= 0)
);

create table public.order_items (
  id            bigint generated always as identity primary key,
  created_at    timestamptz   not null default now(),
  order_id      bigint        not null references public.orders (id) on delete cascade,
  product_id    bigint        references public.products (id) on delete set null,
  product_name  text          not null,
  unit_price    numeric(12,2) not null check (unit_price >= 0),
  quantity      integer       not null check (quantity > 0)
);

create index products_category_idx   on public.products (category_id);
create index products_price_idx      on public.products (price);
create index orders_user_idx         on public.orders (user_id, created_at desc);
create index order_items_order_idx   on public.order_items (order_id);
create index order_items_product_idx on public.order_items (product_id);

create or replace function public.is_admin()
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  return exists (
    select 1
    from public.profiles p
    join public.roles r on r.id = p.role_id
    where p.id = auth.uid() and r.role = 'admin'
  );
end;
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  meta jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  full_name text := coalesce(meta->>'full_name', meta->>'name', '');
begin
  insert into public.profiles (id, email, firstname, lastname, role_id)
  values (
    new.id,
    new.email,
    coalesce(
      nullif(meta->>'firstname', ''),
      nullif(meta->>'given_name', ''),
      nullif(split_part(full_name, ' ', 1), ''),
      meta->>'user_name'
    ),
    coalesce(
      nullif(meta->>'lastname', ''),
      nullif(meta->>'family_name', ''),
      nullif(regexp_replace(full_name, '^\S+\s*', ''), '')
    ),
    (select id from public.roles where role = 'customer')
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

create or replace function public.place_order(items jsonb)
returns json
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user     uuid := auth.uid();
  v_order_id bigint;
  v_total    numeric(12,2) := 0;
  v_line     record;
  v_product  record;
begin
  if v_user is null then
    raise exception 'You must be signed in to place an order.';
  end if;

  if public.is_admin() then
    raise exception 'Admin accounts cannot place orders.';
  end if;

  if items is null or jsonb_typeof(items) <> 'array' or jsonb_array_length(items) = 0 then
    raise exception 'Your cart is empty.';
  end if;

  insert into public.orders (user_id, status, total)
  values (v_user, 'pending', 0)
  returning id into v_order_id;

  for v_line in
    select (e->>'product_id')::bigint     as product_id,
           sum((e->>'quantity')::integer) as quantity
    from jsonb_array_elements(items) as e
    group by 1
    order by 1
  loop
    if v_line.quantity is null or v_line.quantity <= 0 then
      raise exception 'Each item needs a quantity of at least 1.';
    end if;

    select id, name, price, stock
      into v_product
      from public.products
     where id = v_line.product_id
       for update;

    if not found then
      raise exception 'A product in your cart is no longer available.';
    end if;

    if v_product.stock < v_line.quantity then
      raise exception 'Only % left of "%".', v_product.stock, v_product.name;
    end if;

    update public.products
       set stock = stock - v_line.quantity
     where id = v_product.id;

    insert into public.order_items (order_id, product_id, product_name, unit_price, quantity)
    values (v_order_id, v_product.id, v_product.name, v_product.price, v_line.quantity);

    v_total := v_total + v_product.price * v_line.quantity;
  end loop;

  update public.orders
     set total = v_total,
         status = 'done'
   where id = v_order_id;

  return json_build_object('order_id', v_order_id, 'total', v_total);
end;
$$;

revoke execute on function public.place_order(jsonb) from public, anon;
grant execute on function public.place_order(jsonb) to authenticated;
revoke execute on function public.is_admin() from public, anon;
grant execute on function public.is_admin() to authenticated;

alter table public.roles       enable row level security;
alter table public.profiles    enable row level security;
alter table public.categories  enable row level security;
alter table public.products    enable row level security;
alter table public.orders      enable row level security;
alter table public.order_items enable row level security;

create policy "roles read"
  on public.roles for select to authenticated
  using (true);

create policy "profiles read own or admin"
  on public.profiles for select to authenticated
  using (id = (select auth.uid()) or (select public.is_admin()));

create policy "profiles update own"
  on public.profiles for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

revoke update on public.profiles from authenticated, anon;
grant update (firstname, lastname) on public.profiles to authenticated;

create policy "categories read"
  on public.categories for select to authenticated
  using (true);

create policy "categories create"
  on public.categories for insert to authenticated
  with check ((select public.is_admin()));

create policy "categories update"
  on public.categories for update to authenticated
  using ((select public.is_admin()))
  with check ((select public.is_admin()));

create policy "categories delete"
  on public.categories for delete to authenticated
  using ((select public.is_admin()));

create policy "products read"
  on public.products for select to authenticated
  using (true);

create policy "create product"
  on public.products for insert to authenticated
  with check ((select public.is_admin()));

create policy "update product"
  on public.products for update to authenticated
  using ((select public.is_admin()))
  with check ((select public.is_admin()));

create policy "delete product"
  on public.products for delete to authenticated
  using ((select public.is_admin()));

create policy "orders read own or admin"
  on public.orders for select to authenticated
  using (user_id = (select auth.uid()) or (select public.is_admin()));

create policy "orders update status admin"
  on public.orders for update to authenticated
  using ((select public.is_admin()))
  with check ((select public.is_admin()));

revoke insert, update, delete on public.orders from authenticated, anon;
grant update (status) on public.orders to authenticated;

create policy "order items read own or admin"
  on public.order_items for select to authenticated
  using (
    (select public.is_admin())
    or exists (
      select 1 from public.orders o
      where o.id = order_items.order_id and o.user_id = (select auth.uid())
    )
  );

revoke insert, update, delete on public.order_items from authenticated, anon;

insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true)
on conflict (id) do update set public = true;

drop policy if exists "product images read" on storage.objects;

drop policy if exists "product images upload" on storage.objects;
create policy "product images upload"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'product-images' and (select public.is_admin()));

drop policy if exists "product images update" on storage.objects;
create policy "product images update"
  on storage.objects for update to authenticated
  using (bucket_id = 'product-images' and (select public.is_admin()));

drop policy if exists "product images delete" on storage.objects;
create policy "product images delete"
  on storage.objects for delete to authenticated
  using (bucket_id = 'product-images' and (select public.is_admin()));

insert into public.roles (role) values ('customer'), ('admin');

insert into public.categories (name) values ('Electric Guitar'), ('Bass Guitar');

insert into public.products (name, description, price, stock, image_url, category_id)
select p.name, p.description, p.price, p.stock, p.image_url, c.id
from (values
  ('355 Epiphone Semi-Hollow', 'A warm, expressive semi-hollow electric guitar made for big chords, smooth leads, and everything between.', 52999, 2, 'assets/images/products/epiphone_355.png', 'Electric Guitar'),
  ('Skywing ST-0035 Electric Guitar (Black)', 'A sleek, entry-level S-type electric guitar featuring a timeless glossy black finish, versatile pickup configuration, and a comfortable neck profile—ideal for beginner and intermediate players seeking classic rock and blues tones.', 49999, 6, 'assets/images/products/stratocaster_skywing.png', 'Electric Guitar'),
  ('Global B1 Bass', 'A versatile 4-string electric bass featuring a vibrant translucent blue finish, a deep, resonant tone, and an ergonomic body design—delivering solid punch and low-end clarity suited for funk, rock, and modern grooves.', 15999, 8, 'assets/images/products/bass_global.png', 'Bass Guitar'),
  ('Bass Guitar – B2 Global', 'A versatile 5-string electric bass with a smooth, natural wood finish, offering an expanded low-end range, balanced active/passive punch, and an ergonomic neck—built to deliver rich, thunderous low frequencies for modern rock, jazz, and gospel setups.', 23999, 5, 'assets/images/products/bass_globalnatural.png', 'Bass Guitar'),
  ('Pulse ST – 0037 Electric Guitar (Red)', 'A vibrant double-cutaway electric guitar boasting an eye-catching metallic red finish, versatile pickup versatility, and a fast, comfortable neck—crafted to deliver crisp highs and punchy tones for everything from sharp rhythm to soaring solos.', 8999, 0, 'assets/images/products/telecaster_pulsered.png', 'Electric Guitar'),
  ('Skywing ST-0035 Electric Guitar (Sunburst)', 'A classic double-cutaway electric guitar showcasing a vibrant, traditional sunburst finish, versatile pickup configuration, and an easy-playing neck—delivering rich tone and timeless style perfect for blues, rock, and pop.', 18999, 10, 'assets/images/products/stratocaster_skywingsunburst.png', 'Electric Guitar'),
  ('Skywing ST-0035 Electric Guitar (Blue)', 'A dynamic double-cutaway electric guitar featuring a striking, high-gloss blue finish, versatile pickup configuration, and a smooth, accessible neck—offering bright, crisp tones and modern style ideal for rock, pop, and blues.', 9995, 12, 'assets/images/products/stratocaster_skywingblue.png', 'Electric Guitar'),
  ('355 Epiphone Semi-Hollow (Blue)', 'A premium semi-hollowbody electric guitar featuring a striking blue finish (such as Pelham Blue), dual humbucking pickups, elegant multi-ply binding, and classic block inlays—delivering rich, warm resonance, smooth sustain, and upscale vintage style perfect for jazz, blues, and classic rock.', 9995, 4, 'assets/images/products/semi_hollow_blue.jpg', 'Electric Guitar'),
  ('Global B2 Bass (Starter)', 'An affordable 4-string starter bass with a comfortable slim neck and a punchy passive pickup, made for first gigs, practice rooms and learning your first grooves.', 6685, 15, 'assets/images/products/bass_globalb2.png', 'Bass Guitar')
) as p(name, description, price, stock, image_url, category)
join public.categories c on c.name = p.category;

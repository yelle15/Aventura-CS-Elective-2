create table if not exists public.products (
  id          text primary key,
  name        text          not null,
  category    text          not null,
  price       numeric(10,2) not null check (price >= 0),
  image_path  text          not null,
  description text          not null default '',
  rating      numeric(2,1)  not null default 0 check (rating between 0 and 5),
  is_new      boolean       not null default false,
  is_on_sale  boolean       not null default false,
  old_price   numeric(10,2),
  image_scale numeric(4,2)  not null default 1,
  created_at  timestamptz   not null default now()
);

create index if not exists products_price_idx    on public.products (price);
create index if not exists products_category_idx on public.products (category);

alter table public.products enable row level security;

drop policy if exists "Products are readable by everyone" on public.products;
create policy "Products are readable by everyone"
  on public.products for select
  to anon, authenticated
  using (true);

drop policy if exists "Products can be inserted" on public.products;
create policy "Products can be inserted"
  on public.products for insert
  to anon, authenticated
  with check (true);

drop policy if exists "Products can be updated" on public.products;
create policy "Products can be updated"
  on public.products for update
  to anon, authenticated
  using (true)
  with check (true);

drop policy if exists "Products can be deleted" on public.products;
create policy "Products can be deleted"
  on public.products for delete
  to anon, authenticated
  using (true);

insert into public.products
  (id, name, category, price, image_path, description, rating, is_new, is_on_sale, old_price, image_scale)
values
  ('355-epiphone', '355 Epiphone Semi-Hollow', 'Electric Guitar', 52999, 'assets/images/products/epiphone_355.png', 'A warm, expressive semi-hollow electric guitar made for big chords, smooth leads, and everything between.', 4.8, true, false, null, 1.8),
  ('stratocaster-skywing', 'Skywing ST-0035 Electric Guitar (Black)', 'Electric Guitar', 49999, 'assets/images/products/stratocaster_skywing.png', 'A sleek, entry-level S-type electric guitar featuring a timeless glossy black finish, versatile pickup configuration, and a comfortable neck profile—ideal for beginner and intermediate players seeking classic rock and blues tones.', 4.7, true, false, null, 1.6),
  ('global-b1-bass', 'Global B1 Bass', 'Bass Guitar', 15999, 'assets/images/products/bass_global.png', 'A versatile 4-string electric bass featuring a vibrant translucent blue finish, a deep, resonant tone, and an ergonomic body design—delivering solid punch and low-end clarity suited for funk, rock, and modern grooves.', 4.9, false, false, null, 1.6),
  ('global-b2-bass', 'Bass Guitar – B2 Global', 'Bass Guitar', 23999, 'assets/images/products/bass_globalnatural.png', 'A versatile 5-string electric bass with a smooth, natural wood finish, offering an expanded low-end range, balanced active/passive punch, and an ergonomic neck—built to deliver rich, thunderous low frequencies for modern rock, jazz, and gospel setups.', 4.6, false, false, null, 1.6),
  ('pulse-st-0037-guitar', 'Pulse ST – 0037 Electric Guitar (Red)', 'Electric Guitar', 8999, 'assets/images/products/telecaster_pulsered.png', 'A vibrant double-cutaway electric guitar boasting an eye-catching metallic red finish, versatile pickup versatility, and a fast, comfortable neck—crafted to deliver crisp highs and punchy tones for everything from sharp rhythm to soaring solos.', 4.5, false, false, null, 1.6),
  ('stratocaster-skywing-sunburst', 'Skywing ST-0035 Electric Guitar (Sunburst)', 'Electric Guitar', 18999, 'assets/images/products/stratocaster_skywingsunburst.png', 'A classic double-cutaway electric guitar showcasing a vibrant, traditional sunburst finish, versatile pickup configuration, and an easy-playing neck—delivering rich tone and timeless style perfect for blues, rock, and pop.', 4.7, false, false, null, 1.6),
  ('stratocaster-skywing-blue', 'Skywing ST-0035 Electric Guitar (Blue)', 'Electric Guitar', 9995, 'assets/images/products/stratocaster_skywingblue.png', 'A dynamic double-cutaway electric guitar featuring a striking, high-gloss blue finish, versatile pickup configuration, and a smooth, accessible neck—offering bright, crisp tones and modern style ideal for rock, pop, and blues.', 4.7, false, false, null, 1.6),
  ('semi-hollow-blue', '355 Epiphone Semi-Hollow (Blue)', 'Electric Guitar', 9995, 'assets/images/products/semi_hollow_blue.jpg', 'A premium semi-hollowbody electric guitar featuring a striking blue finish (such as Pelham Blue), dual humbucking pickups, elegant multi-ply binding, and classic block inlays—delivering rich, warm resonance, smooth sustain, and upscale vintage style perfect for jazz, blues, and classic rock.', 4.8, false, false, null, 1.6),
  ('bass-guitar-b2-global', 'Bass Guitar – B2 Global', 'Bass Guitar', 6685, 'assets/images/products/bass_globalb2.png', 'A premium semi-hollowbody electric guitar featuring a striking blue finish (such as Pelham Blue), dual humbucking pickups, elegant multi-ply binding, and classic block inlays—delivering rich, warm resonance, smooth sustain, and upscale vintage style perfect for jazz, blues, and classic rock.', 4.8, false, false, null, 1.6)

on conflict (id) do nothing;

update public.products set category = 'Electric Guitar' where category = 'Electric Guitars';
update public.products set category = 'Bass Guitar'     where category = 'Bass Guitars';

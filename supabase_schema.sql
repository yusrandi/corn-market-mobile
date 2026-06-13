-- ============================================================
-- CornMarket — Supabase SQL Schema
-- Jalankan file ini di: Supabase Dashboard → SQL Editor → Run
-- ============================================================

-- ── Extensions ──────────────────────────────────────────────
create extension if not exists "uuid-ossp";

-- ── 1. PROFILES ─────────────────────────────────────────────
-- Extends Supabase auth.users
create table if not exists public.profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  name         text not null default '',
  phone        text default '',
  address      text default '',
  avatar_url   text default '',
  total_orders int  default 0,
  total_spent  numeric(12,2) default 0,
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1))
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ── 2. CATEGORIES ───────────────────────────────────────────
create table if not exists public.categories (
  id          uuid primary key default uuid_generate_v4(),
  name        text not null,
  slug        text not null unique,
  emoji       text default '🌽',
  description text default '',
  sort_order  int  default 0,
  created_at  timestamptz default now()
);

-- Seed categories
insert into public.categories (name, slug, emoji, description, sort_order) values
  ('Semua',  'all',    '🌽', 'Semua produk jagung',    0),
  ('Segar',  'segar',  '🌱', 'Jagung segar pilihan',   1),
  ('Manis',  'manis',  '🍯', 'Jagung manis premium',   2),
  ('Olahan', 'olahan', '🏭', 'Produk olahan jagung',   3),
  ('Benih',  'benih',  '🌾', 'Benih jagung unggul',    4)
on conflict (slug) do nothing;

-- ── 3. PRODUCTS ─────────────────────────────────────────────
create table if not exists public.products (
  id             uuid primary key default uuid_generate_v4(),
  name           text not null,
  description    text default '',
  price          numeric(10,2) not null,
  price_per_unit numeric(10,2) not null,
  unit           text not null default 'kg',
  image_url      text default '',
  image_urls     text[] default '{}',     -- multiple images
  category_id    uuid references public.categories(id),
  category_slug  text not null default 'segar',
  rating         numeric(3,2) default 0,
  review_count   int default 0,
  is_popular     boolean default false,
  is_new         boolean default false,
  stock          int default 0,
  origin         text default '',
  is_active      boolean default true,
  created_at     timestamptz default now(),
  updated_at     timestamptz default now()
);

-- Seed products
insert into public.products (name, description, price, price_per_unit, unit, image_url, category_slug, rating, review_count, is_popular, is_new, stock, origin) values
  ('Jagung Manis Super',   'Jagung manis pilihan dari petani lokal Kalimantan Timur. Dipanen segar setiap hari dengan kadar gula tinggi.', 25000, 5000, 'kg',      'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=400', 'manis',  4.9, 312, true,  false, 150, 'Kutai Kartanegara, Kaltim'),
  ('Jagung Pipil Kering',  'Jagung pipil kering berkualitas tinggi, siap olah untuk berbagai kebutuhan industri maupun rumah tangga.',   18000, 3600, 'kg',      'https://images.unsplash.com/photo-1489421506538-13b72c0e6c77?w=400', 'olahan', 4.7, 187, true,  false, 500, 'Berau, Kaltim'),
  ('Jagung Segar Lokal',   'Jagung segar lokal yang dipetik langsung dari kebun. Cocok untuk direbus, dibakar, atau diolah.',            15000, 3000, 'kg',      'https://images.unsplash.com/photo-1601593346740-925612772716?w=400', 'segar',  4.6,  98, false, true,  200, 'Penajam, Kaltim'),
  ('Benih Jagung NK-212',  'Benih jagung hibrida unggul dengan produktivitas 10-12 ton/ha. Tahan penyakit, cocok iklim Kalimantan.',    85000,85000, 'bungkus', 'https://images.unsplash.com/photo-1587132137056-bfbf0166836e?w=400', 'benih',  4.8, 256, true,  false,  75, 'Samarinda, Kaltim'),
  ('Jagung Pulut Ketan',   'Jagung pulut dengan tekstur lengket khas, sangat populer di Kalimantan. Sempurna untuk kue tradisional.',   30000, 6000, 'kg',      'https://images.unsplash.com/photo-1559181567-c3190ca9d5db?w=400', 'manis',  4.5, 143, false, true,   80, 'Balikpapan, Kaltim'),
  ('Tepung Jagung Premium','Tepung jagung halus hasil olahan modern, bebas gluten, cocok untuk berbagai kebutuhan memasak.',            22000,22000, 'kg',      'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400', 'olahan', 4.4,  67, false, true,  300, 'Samarinda, Kaltim')
on conflict do nothing;

-- ── 4. BANNERS ──────────────────────────────────────────────
create table if not exists public.banners (
  id               uuid primary key default uuid_generate_v4(),
  title            text not null,
  subtitle         text default '',
  image_url        text default '',
  background_color text default 'F5C518',
  action_label     text default 'Lihat',
  sort_order       int  default 0,
  is_active        boolean default true,
  created_at       timestamptz default now()
);

insert into public.banners (title, subtitle, image_url, background_color, action_label, sort_order) values
  ('Jagung Manis' || chr(10) || 'Super Premium',   'Langsung dari kebun petani' || chr(10) || 'lokal Kalimantan', 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=400', 'F5C518', 'Belanja Sekarang', 1),
  ('Gratis Ongkir' || chr(10) || 'se-Kalimantan',  'Minimum pembelian' || chr(10) || '50.000 saja!',              'https://images.unsplash.com/photo-1559181567-c3190ca9d5db?w=400', '2D6A4F', 'Klaim Promo',      2),
  ('Benih Unggul'  || chr(10) || 'Hasil Terbaik',  'Produktivitas tinggi' || chr(10) || 'cocok lahan lokal',      'https://images.unsplash.com/photo-1587132137056-bfbf0166836e?w=400', '52B788', 'Lihat Koleksi',    3)
on conflict do nothing;

-- ── 5. REVIEWS ──────────────────────────────────────────────
create table if not exists public.reviews (
  id          uuid primary key default uuid_generate_v4(),
  product_id  uuid not null references public.products(id) on delete cascade,
  user_id     uuid references public.profiles(id) on delete set null,
  user_name   text not null default 'Anonim',
  user_avatar text default '',
  rating      numeric(3,2) not null check (rating >= 1 and rating <= 5),
  comment     text default '',
  images      text[] default '{}',
  is_verified boolean default false,
  created_at  timestamptz default now()
);

-- ── 6. ORDERS ───────────────────────────────────────────────
create table if not exists public.orders (
  id              uuid primary key default uuid_generate_v4(),
  order_number    text not null unique,
  user_id         uuid not null references public.profiles(id) on delete cascade,
  status          text not null default 'pending'
                    check (status in ('pending','confirmed','processing','shipped','delivered','cancelled')),
  subtotal        numeric(12,2) not null default 0,
  shipping_fee    numeric(10,2) not null default 0,
  total           numeric(12,2) not null default 0,
  address         text not null default '',
  payment_method  text not null default '',
  tracking_number text default '',
  notes           text default '',
  created_at      timestamptz default now(),
  updated_at      timestamptz default now()
);

-- Generate order number trigger
create or replace function public.generate_order_number()
returns trigger language plpgsql as $$
begin
  new.order_number := 'CM-' || to_char(now(), 'YYYY') || '-' || lpad(nextval('order_seq')::text, 4, '0');
  return new;
end;
$$;

create sequence if not exists order_seq start 1;

drop trigger if exists set_order_number on public.orders;
create trigger set_order_number
  before insert on public.orders
  for each row execute procedure public.generate_order_number();

-- ── 7. ORDER ITEMS ──────────────────────────────────────────
create table if not exists public.order_items (
  id         uuid primary key default uuid_generate_v4(),
  order_id   uuid not null references public.orders(id) on delete cascade,
  product_id uuid not null references public.products(id),
  name       text not null,           -- snapshot saat order
  image_url  text default '',
  price      numeric(10,2) not null,
  quantity   int not null default 1,
  subtotal   numeric(12,2) not null,
  unit       text default 'kg',
  created_at timestamptz default now()
);

-- ── 8. CART (persistent, opsional) ──────────────────────────
create table if not exists public.cart_items (
  id         uuid primary key default uuid_generate_v4(),
  user_id    uuid not null references public.profiles(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  quantity   int not null default 1,
  created_at timestamptz default now(),
  unique (user_id, product_id)
);

-- ── 9. FAVORITES ────────────────────────────────────────────
create table if not exists public.favorites (
  id         uuid primary key default uuid_generate_v4(),
  user_id    uuid not null references public.profiles(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  created_at timestamptz default now(),
  unique (user_id, product_id)
);

-- ── 10. ROW LEVEL SECURITY ──────────────────────────────────

-- profiles: user hanya bisa baca/update miliknya
alter table public.profiles enable row level security;
create policy "profiles_select" on public.profiles for select using (true);
create policy "profiles_update" on public.profiles for update using (auth.uid() = id);

-- products: semua bisa baca, hanya service role yg bisa write
alter table public.products enable row level security;
create policy "products_select" on public.products for select using (is_active = true);

-- categories: semua bisa baca
alter table public.categories enable row level security;
create policy "categories_select" on public.categories for select using (true);

-- banners: semua bisa baca
alter table public.banners enable row level security;
create policy "banners_select" on public.banners for select using (is_active = true);

-- reviews: semua bisa baca, user bisa insert miliknya
alter table public.reviews enable row level security;
create policy "reviews_select" on public.reviews for select using (true);
create policy "reviews_insert" on public.reviews for insert with check (auth.uid() = user_id);

-- orders: user hanya akses pesanannya
alter table public.orders enable row level security;
create policy "orders_select" on public.orders for select using (auth.uid() = user_id);
create policy "orders_insert" on public.orders for insert with check (auth.uid() = user_id);
create policy "orders_update" on public.orders for update using (auth.uid() = user_id);

-- order_items: ikut orders
alter table public.order_items enable row level security;
create policy "order_items_select" on public.order_items for select
  using (exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid()));
create policy "order_items_insert" on public.order_items for insert
  with check (exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid()));

-- cart: user hanya akses cart-nya
alter table public.cart_items enable row level security;
create policy "cart_select" on public.cart_items for select using (auth.uid() = user_id);
create policy "cart_insert" on public.cart_items for insert with check (auth.uid() = user_id);
create policy "cart_update" on public.cart_items for update using (auth.uid() = user_id);
create policy "cart_delete" on public.cart_items for delete using (auth.uid() = user_id);

-- favorites: user hanya akses favoritnya
alter table public.favorites enable row level security;
create policy "favorites_select" on public.favorites for select using (auth.uid() = user_id);
create policy "favorites_insert" on public.favorites for insert with check (auth.uid() = user_id);
create policy "favorites_delete" on public.favorites for delete using (auth.uid() = user_id);

-- ── 11. STORAGE BUCKETS ─────────────────────────────────────
-- Jalankan di Supabase Dashboard → Storage → New Bucket
-- Atau via SQL (membutuhkan service role):

-- insert into storage.buckets (id, name, public) values ('products', 'products', true) on conflict do nothing;
-- insert into storage.buckets (id, name, public) values ('avatars',  'avatars',  true) on conflict do nothing;

-- Storage policies (setelah buat bucket):
-- create policy "products_public_read"  on storage.objects for select using (bucket_id = 'products');
-- create policy "products_auth_upload"  on storage.objects for insert with check (bucket_id = 'products' and auth.role() = 'authenticated');
-- create policy "avatars_public_read"   on storage.objects for select using (bucket_id = 'avatars');
-- create policy "avatars_auth_upload"   on storage.objects for insert with check (bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]);

-- ── 12. UPDATE FUNCTION (updated_at auto) ───────────────────
create or replace function public.handle_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger set_updated_at before update on public.products
  for each row execute procedure public.handle_updated_at();

create trigger set_updated_at before update on public.orders
  for each row execute procedure public.handle_updated_at();

create trigger set_updated_at before update on public.profiles
  for each row execute procedure public.handle_updated_at();

-- ── DONE ────────────────────────────────────────────────────
-- Setelah menjalankan ini:
-- 1. Buat bucket 'products' dan 'avatars' di Storage (public)
-- 2. Copy URL & anon key dari Settings → API
-- 3. Paste ke lib/core/config/supabase_config.dart

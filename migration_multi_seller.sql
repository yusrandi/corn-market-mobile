-- ============================================================
-- Migration: Multi-Seller Architecture
-- Jalankan di Supabase Dashboard → SQL Editor
-- ============================================================

-- ── 1. TAMBAH KOLOM ROLE KE PROFILES ────────────────────────
alter table public.profiles
  add column if not exists role text not null default 'buyer'
    check (role in ('buyer', 'seller', 'admin'));

-- Set existing users as buyer
update public.profiles set role = 'buyer' where role is null;

-- ── 2. STORES ────────────────────────────────────────────────
create table if not exists public.stores (
  id            uuid primary key default uuid_generate_v4(),
  owner_id      uuid not null references public.profiles(id) on delete cascade,
  name          text not null,
  slug          text not null unique,
  description   text default '',
  logo_url      text default '',
  banner_url    text default '',
  address       text default '',
  city          text default '',
  province      text default '',
  phone         text default '',
  whatsapp      text default '',
  is_active     boolean default false,   -- admin yang approve
  is_verified   boolean default false,
  rating        numeric(3,2) default 0,
  total_sales   int default 0,
  total_products int default 0,
  created_at    timestamptz default now(),
  updated_at    timestamptz default now(),
  unique (owner_id)  -- 1 seller = 1 store
);

-- ── 3. SELLER APPLICATIONS ───────────────────────────────────
-- Formulir registrasi penjual (sebelum diapprove)
create table if not exists public.seller_applications (
  id            uuid primary key default uuid_generate_v4(),
  name          text not null,
  email         text not null unique,
  phone         text not null,
  store_name    text not null,
  store_address text not null,
  city          text not null,
  province      text not null,
  description   text default '',
  id_card_url   text default '',      -- foto KTP
  store_photo_url text default '',    -- foto toko
  status        text default 'pending'
                  check (status in ('pending', 'approved', 'rejected')),
  reject_reason text default '',
  reviewed_by   uuid references public.profiles(id),
  reviewed_at   timestamptz,
  created_at    timestamptz default now()
);

-- ── 4. UPDATE PRODUCTS → TAMBAH STORE_ID ─────────────────────
alter table public.products
  add column if not exists store_id   uuid references public.stores(id) on delete set null,
  add column if not exists store_name text default 'CornMarket Official';

-- Buat default store untuk produk lama (official store)
do $$
declare
  v_admin_id  uuid;
  v_store_id  uuid;
begin
  -- Cari admin user pertama, atau skip jika belum ada
  select id into v_admin_id from public.profiles where role = 'admin' limit 1;
  if v_admin_id is not null then
    insert into public.stores (owner_id, name, slug, description, is_active, is_verified)
    values (v_admin_id, 'CornMarket Official', 'official', 'Toko resmi CornMarket', true, true)
    on conflict (slug) do nothing
    returning id into v_store_id;

    if v_store_id is not null then
      update public.products set store_id = v_store_id, store_name = 'CornMarket Official'
      where store_id is null;
    end if;
  end if;
end $$;

-- ── 5. UPDATE CONVERSATIONS → SELLER CHAT ────────────────────
alter table public.conversations
  add column if not exists seller_id    uuid references public.profiles(id),
  add column if not exists store_id     uuid references public.stores(id),
  add column if not exists store_name   text default '',
  add column if not exists chat_type    text default 'support'
                              check (chat_type in ('support', 'seller'));
-- chat_type:
--   'support' = buyer ↔ admin
--   'seller'  = buyer ↔ seller toko

-- Drop unique constraint lama (user_id), ganti dengan (user_id, seller_id)
alter table public.conversations drop constraint if exists conversations_user_id_key;
alter table public.conversations
  add constraint conversations_user_seller_unique unique (user_id, seller_id);

-- Update conversations lama as support type
update public.conversations set chat_type = 'support' where chat_type is null;

-- ── 6. UPDATE MESSAGES → SENDER ROLE ─────────────────────────
-- Tambah 'seller' sebagai sender_role yang valid
alter table public.messages
  drop constraint if exists messages_sender_role_check;
alter table public.messages
  add constraint messages_sender_role_check
    check (sender_role in ('user', 'admin', 'seller'));

-- ── 7. RLS STORES ────────────────────────────────────────────
alter table public.stores enable row level security;

create policy "stores_public_read" on public.stores
  for select using (is_active = true);

create policy "stores_owner_read" on public.stores
  for select using (auth.uid() = owner_id);

create policy "stores_owner_update" on public.stores
  for update using (auth.uid() = owner_id);

-- ── 8. RLS SELLER APPLICATIONS ───────────────────────────────
alter table public.seller_applications enable row level security;

-- Siapapun bisa insert (public registration)
create policy "applications_insert" on public.seller_applications
  for insert with check (true);

-- Hanya yang mengajukan bisa baca (berdasarkan email, sebelum login)
create policy "applications_owner_select" on public.seller_applications
  for select using (true);  -- admin baca semua via service role

-- ── 9. RLS PRODUCTS UPDATE → SELLER BISA MANAGE PRODUKNYA ───
-- Drop policy lama
drop policy if exists "products_select" on public.products;

create policy "products_public_select" on public.products
  for select using (is_active = true);

create policy "products_seller_insert" on public.products
  for insert with check (
    exists (select 1 from public.stores s where s.id = store_id and s.owner_id = auth.uid())
  );

create policy "products_seller_update" on public.products
  for update using (
    exists (select 1 from public.stores s where s.id = store_id and s.owner_id = auth.uid())
  );

create policy "products_seller_delete" on public.products
  for delete using (
    exists (select 1 from public.stores s where s.id = store_id and s.owner_id = auth.uid())
  );

-- ── 10. FUNCTION: GET OR CREATE SELLER CONVERSATION ──────────
create or replace function public.get_or_create_seller_conversation(
  p_buyer_id  uuid,
  p_seller_id uuid,
  p_store_id  uuid
) returns uuid language plpgsql security definer as $$
declare
  v_conv_id  uuid;
  v_store_nm text;
  v_buy_nm   text;
begin
  select id into v_conv_id
  from   public.conversations
  where  user_id = p_buyer_id and seller_id = p_seller_id;

  if v_conv_id is null then
    select name into v_store_nm from public.stores where id = p_store_id;
    select name into v_buy_nm   from public.profiles where id = p_buyer_id;

    insert into public.conversations
      (user_id, user_name, seller_id, store_id, store_name, chat_type)
    values
      (p_buyer_id, coalesce(v_buy_nm,''), p_seller_id, p_store_id, coalesce(v_store_nm,''), 'seller')
    returning id into v_conv_id;
  end if;

  return v_conv_id;
end;
$$;

-- ── 11. FUNCTION: APPROVE SELLER ─────────────────────────────
create or replace function public.approve_seller(
  p_application_id uuid,
  p_admin_id       uuid
) returns void language plpgsql security definer as $$
declare
  v_app public.seller_applications%rowtype;
  v_user_id uuid;
  v_slug text;
begin
  select * into v_app from public.seller_applications where id = p_application_id;

  -- Cari atau buat user auth
  select id into v_user_id from public.profiles
  where id in (select id from auth.users where email = v_app.email);

  if v_user_id is not null then
    -- Update role
    update public.profiles set role = 'seller' where id = v_user_id;

    -- Buat store
    v_slug := lower(regexp_replace(v_app.store_name, '[^a-zA-Z0-9]', '-', 'g'));
    insert into public.stores
      (owner_id, name, slug, description, address, city, province, phone, is_active, is_verified)
    values
      (v_user_id, v_app.store_name, v_slug, v_app.description,
       v_app.store_address, v_app.city, v_app.province, v_app.phone, true, true)
    on conflict (owner_id) do update set is_active = true;
  end if;

  -- Update application
  update public.seller_applications set
    status      = 'approved',
    reviewed_by = p_admin_id,
    reviewed_at = now()
  where id = p_application_id;
end;
$$;

-- ── 12. TRIGGERS ─────────────────────────────────────────────
create trigger set_updated_at before update on public.stores
  for each row execute procedure public.handle_updated_at();

-- ── STORAGE BUCKET ───────────────────────────────────────────
-- Buat manual di Storage dashboard:
-- 'store-assets' (public: true) → logo, banner toko
-- 'id-cards' (public: false)    → foto KTP seller

-- ── DONE ────────────────────────────────────────────────────
-- Summary perubahan:
-- ✅ profiles.role → buyer / seller / admin
-- ✅ tabel stores (1 seller = 1 store)
-- ✅ tabel seller_applications (registrasi publik)
-- ✅ products.store_id, products.store_name
-- ✅ conversations.seller_id, chat_type seller/support
-- ✅ RLS updated untuk seller manage produk sendiri

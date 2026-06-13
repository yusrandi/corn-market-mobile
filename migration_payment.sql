-- ============================================================
-- Migration: Payment Proof via Bank Transfer
-- Jalankan di Supabase Dashboard → SQL Editor
-- ============================================================

-- Tambah kolom payment ke tabel orders
alter table public.orders
  add column if not exists bank_name        text default '',
  add column if not exists bank_account     text default '',
  add column if not exists bank_holder      text default '',
  add column if not exists payment_proof_url text default '',
  add column if not exists payment_status   text default 'unpaid'
    check (payment_status in ('unpaid','pending_verification','verified','rejected'));

-- Buat storage bucket untuk bukti pembayaran (jalankan manual di Storage dashboard)
-- Bucket name: 'payment-proofs'  |  Public: false (private!)

-- Storage policy: user hanya bisa upload ke folder miliknya
-- create policy "payment_proof_upload"
--   on storage.objects for insert
--   with check (bucket_id = 'payment-proofs' and auth.role() = 'authenticated');

-- create policy "payment_proof_read_own"
--   on storage.objects for select
--   using (bucket_id = 'payment-proofs' and auth.uid()::text = (storage.foldername(name))[1]);

-- Admin bisa baca semua (gunakan service role key di admin panel)
-- create policy "payment_proof_read_admin"
--   on storage.objects for select
--   using (bucket_id = 'payment-proofs');

-- Update RLS orders: allow update payment_proof_url by owner
create policy "orders_update_payment" on public.orders
  for update using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- View untuk admin: orders dengan payment proof
create or replace view public.orders_payment_view as
  select
    o.id,
    o.order_number,
    o.user_id,
    o.total,
    o.status,
    o.payment_status,
    o.bank_name,
    o.bank_account,
    o.bank_holder,
    o.payment_proof_url,
    o.created_at,
    o.updated_at,
    p.name  as customer_name,
    p.phone as customer_phone
  from public.orders o
  left join public.profiles p on p.id = o.user_id;

-- Tambah kolom penanda bahwa user sudah signup via Supabase Auth
alter table public.seller_applications
  add column if not exists auth_user_id uuid references auth.users(id),
  add column if not exists has_account  boolean default false;

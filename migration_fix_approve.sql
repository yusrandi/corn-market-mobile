-- ============================================================
-- Fix: approve_seller function
-- User sudah signup saat registrasi, approve hanya update role + buat store
-- ============================================================

create or replace function public.approve_seller(
  p_application_id uuid,
  p_admin_id       uuid
) returns void language plpgsql security definer as $$
declare
  v_app    public.seller_applications%rowtype;
  v_user_id uuid;
  v_slug   text;
  v_count  int;
begin
  -- Ambil data aplikasi
  select * into v_app from public.seller_applications where id = p_application_id;
  if not found then
    raise exception 'Application not found';
  end if;

  -- Cari user berdasarkan email di auth.users
  select id into v_user_id
  from auth.users
  where email = lower(trim(v_app.email))
  limit 1;

  if v_user_id is null then
    raise exception 'User dengan email % belum terdaftar. Seller harus signup dulu.', v_app.email;
  end if;

  -- Update role di profiles
  update public.profiles
  set role = 'seller', name = coalesce(nullif(name,''), v_app.name)
  where id = v_user_id;

  -- Buat slug unik
  v_slug := lower(regexp_replace(v_app.store_name, '[^a-zA-Z0-9]', '-', 'g'));

  -- Pastikan slug unik (append angka jika duplikat)
  select count(*) into v_count from public.stores where slug = v_slug;
  if v_count > 0 then
    v_slug := v_slug || '-' || floor(random() * 900 + 100)::text;
  end if;

  -- Buat store
  insert into public.stores (
    owner_id, name, slug, description,
    address, city, province, phone,
    is_active, is_verified
  ) values (
    v_user_id, v_app.store_name, v_slug, v_app.description,
    v_app.store_address, v_app.city, v_app.province, v_app.phone,
    true, true
  )
  on conflict (owner_id) do update set
    is_active   = true,
    is_verified = true,
    name        = excluded.name;

  -- Update status aplikasi
  update public.seller_applications set
    status      = 'approved',
    reviewed_by = p_admin_id,
    reviewed_at = now()
  where id = p_application_id;

end;
$$;

-- ── Juga update handle_new_user trigger ──────────────────────
-- Pastikan user baru yang signup (calon seller) dapat role 'buyer' dulu
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, name, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
    'buyer'   -- default buyer, akan diupdate saat approve seller
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

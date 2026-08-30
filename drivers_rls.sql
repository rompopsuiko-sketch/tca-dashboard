-- Włączenie RLS na public.drivers z regułami jak w events / fuels / shifts:
--   anon: SELECT / INSERT / UPDATE dozwolone, DELETE zabronione.
-- Uruchom w Supabase -> SQL Editor. Bezpieczne do ponownego uruchomienia.

-- Uprawnienia dla klucza anon (jawnie, niezależnie od default privileges)
grant select, insert, update on public.drivers to anon;
revoke delete on public.drivers from anon;

-- RLS
alter table public.drivers enable row level security;

-- SELECT
drop policy if exists "drivers anon select" on public.drivers;
create policy "drivers anon select" on public.drivers
  for select to anon using (true);

-- INSERT
drop policy if exists "drivers anon insert" on public.drivers;
create policy "drivers anon insert" on public.drivers
  for insert to anon with check (true);

-- UPDATE
drop policy if exists "drivers anon update" on public.drivers;
create policy "drivers anon update" on public.drivers
  for update to anon using (true) with check (true);

-- DELETE: brak polityki => RLS domyślnie zabrania

-- Odśwież cache schematu PostgREST
notify pgrst, 'reload schema';

-- (opcjonalnie) sprawdzenie po wykonaniu:
-- select policyname, cmd, roles, qual, with_check
-- from pg_policies where schemaname = 'public' and tablename = 'drivers' order by cmd;

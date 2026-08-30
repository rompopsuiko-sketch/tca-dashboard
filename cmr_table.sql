-- Tabela metadanych zdjęć CMR (aplikacja mobilna: app/cmr.tsx wstawia tu rekord po uploadzie do bucketa `cmr-photos`)
-- Uruchom w Supabase → SQL Editor. Bezpieczne do ponownego uruchomienia.

create table if not exists public.cmr (
  id          uuid        primary key default gen_random_uuid(),
  shift_id    uuid        references public.shifts(id) on delete set null,
  driver_name text,
  truck       text,
  tour_number text        not null,
  photo_url   text        not null,
  created_at  timestamptz not null default now()
);

create index if not exists cmr_tour_number_idx on public.cmr (tour_number);
create index if not exists cmr_driver_name_idx on public.cmr (driver_name);
create index if not exists cmr_created_at_idx  on public.cmr (created_at desc);
create index if not exists cmr_shift_id_idx    on public.cmr (shift_id);

-- Uprawnienia dla klucza anon (aplikacja i dashboard używają anon key)
grant select, insert on public.cmr to anon;
grant all on public.cmr to authenticated, service_role;

-- RLS + polityki (odczyt dla dashboardu, zapis dla aplikacji)
alter table public.cmr enable row level security;

drop policy if exists "cmr anon select" on public.cmr;
create policy "cmr anon select" on public.cmr
  for select to anon using (true);

drop policy if exists "cmr anon insert" on public.cmr;
create policy "cmr anon insert" on public.cmr
  for insert to anon with check (true);

-- Odśwież cache schematu PostgREST (żeby /rest/v1/cmr przestało zwracać 404)
notify pgrst, 'reload schema';

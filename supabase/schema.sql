-- CONFRMED: uitvoeren uitsluitend in een NIEUW Supabase-project, nooit in FastPort.
-- Eerst een afzonderlijk Supabase-project voor CONFRMED aanmaken.
create table if not exists public.bets (
 id text primary key,
 user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 bet_date date not null,
 matches text not null,
 prediction text not null,
 bet_type text not null check (bet_type in ('Single','Builder')),
 odds numeric(10,3) not null check (odds > 1),
 stake numeric(12,2) not null check (stake > 0),
 payout numeric(12,2) check (payout >= 0),
 coupon_id text,
 status text not null check (status in ('open','won','lost','void')),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create unique index if not exists bets_user_coupon_unique on public.bets(user_id,coupon_id) where coupon_id is not null and coupon_id <> '';
create index if not exists bets_owner_date on public.bets(user_id,bet_date desc);
alter table public.bets enable row level security;
create policy "Owners can read bets" on public.bets for select to authenticated using ((select auth.uid()) = user_id);
create policy "Owners can insert bets" on public.bets for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "Owners can update bets" on public.bets for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "Owners can delete bets" on public.bets for delete to authenticated using ((select auth.uid()) = user_id);
grant select, insert, update, delete on public.bets to authenticated;
-- Bij opslag van bewijsscreenshots aparte private Storage-bucket gebruiken
-- en policies op basis van auth.uid() / per-gebruiker mapnaam toevoegen.

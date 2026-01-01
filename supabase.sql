-- Pitch shared board (Supabase) setup
--
-- Run this once in your Supabase SQL editor.
-- Then, in Supabase Dashboard:
-- - Enable Auth: "Anonymous sign-ins" (so phones auto-get a user id)
-- - Enable Realtime replication for the table: public.pitch_boards
--
-- This design avoids GitHub entirely. Guests do not need accounts.

create extension if not exists pgcrypto;

create table if not exists public.pitch_boards (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  state jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.pitch_board_members (
  board_id uuid not null references public.pitch_boards(id) on delete cascade,
  user_id uuid not null,
  created_at timestamptz not null default now(),
  primary key (board_id, user_id)
);

create or replace function public.pitch_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists pitch_boards_set_updated_at on public.pitch_boards;
create trigger pitch_boards_set_updated_at
before update on public.pitch_boards
for each row execute function public.pitch_set_updated_at();

alter table public.pitch_boards enable row level security;
alter table public.pitch_board_members enable row level security;

-- Boards: only members can read/write
drop policy if exists "pitch_boards_select_member" on public.pitch_boards;
create policy "pitch_boards_select_member"
on public.pitch_boards
for select
using (
  exists (
    select 1
    from public.pitch_board_members m
    where m.board_id = pitch_boards.id
      and m.user_id = auth.uid()
  )
);

drop policy if exists "pitch_boards_update_member" on public.pitch_boards;
create policy "pitch_boards_update_member"
on public.pitch_boards
for update
using (
  exists (
    select 1
    from public.pitch_board_members m
    where m.board_id = pitch_boards.id
      and m.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.pitch_board_members m
    where m.board_id = pitch_boards.id
      and m.user_id = auth.uid()
  )
);

drop policy if exists "pitch_boards_insert_authenticated" on public.pitch_boards;
create policy "pitch_boards_insert_authenticated"
on public.pitch_boards
for insert
with check (auth.role() = 'authenticated');

-- Members: each user can only add/read their own membership rows
drop policy if exists "pitch_members_select_self" on public.pitch_board_members;
create policy "pitch_members_select_self"
on public.pitch_board_members
for select
using (user_id = auth.uid());

drop policy if exists "pitch_members_insert_self" on public.pitch_board_members;
create policy "pitch_members_insert_self"
on public.pitch_board_members
for insert
with check (user_id = auth.uid());

-- Helper to generate a short share code (base32-ish)
create or replace function public.pitch_random_code(p_len int default 6)
returns text
language plpgsql
as $$
declare
  alphabet text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  out text := '';
  i int;
begin
  if p_len < 4 then
    p_len := 4;
  end if;
  for i in 1..p_len loop
    out := out || substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1);
  end loop;
  return out;
end;
$$;

-- Create a board from client state, add caller as member
create or replace function public.pitch_create_board(p_state jsonb)
returns table(id uuid, code text, state jsonb, updated_at timestamptz)
language plpgsql
security definer
set search_path = public
as $$
declare
  c text;
  b public.pitch_boards%rowtype;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  -- try a few times to avoid collisions
  for i in 1..12 loop
    c := public.pitch_random_code(6);
    begin
      insert into public.pitch_boards(code, state) values (c, p_state) returning * into b;
      exit;
    exception when unique_violation then
      -- try again
    end;
  end loop;

  if b.id is null then
    raise exception 'failed to create board';
  end if;

  insert into public.pitch_board_members(board_id, user_id)
  values (b.id, auth.uid())
  on conflict do nothing;

  return query select b.id, b.code, b.state, b.updated_at;
end;
$$;

-- Join a board by code, add caller as member, return board
create or replace function public.pitch_join_board(p_code text)
returns table(id uuid, code text, state jsonb, updated_at timestamptz)
language plpgsql
security definer
set search_path = public
as $$
declare
  b public.pitch_boards%rowtype;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  select * into b
  from public.pitch_boards
  where pitch_boards.code = p_code
  limit 1;

  if b.id is null then
    raise exception 'board not found';
  end if;

  insert into public.pitch_board_members(board_id, user_id)
  values (b.id, auth.uid())
  on conflict do nothing;

  return query select b.id, b.code, b.state, b.updated_at;
end;
$$;

grant execute on function public.pitch_create_board(jsonb) to anon, authenticated;
grant execute on function public.pitch_join_board(text) to anon, authenticated;
grant execute on function public.pitch_random_code(int) to anon, authenticated;

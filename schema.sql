-- Wing Woman Weekday — Supabase Schema
-- Paste this entire file into Supabase > SQL Editor > Run

-- Sessions: one per "single girl" setup
create table if not exists ww_sessions (
  id uuid primary key default gen_random_uuid(),
  host_name text not null,
  created_at timestamptz default now()
);

-- Available dates the host picked
create table if not exists ww_dates (
  id uuid primary key default gen_random_uuid(),
  session_id uuid references ww_sessions(id) on delete cascade,
  date_iso text not null,  -- e.g. "2026-04-15"
  created_at timestamptz default now()
);

-- Friends the host added
create table if not exists ww_friends (
  id uuid primary key default gen_random_uuid(),
  session_id uuid references ww_sessions(id) on delete cascade,
  name text not null,
  phone text,
  claim_token text unique default encode(gen_random_bytes(6), 'hex'),
  created_at timestamptz default now()
);

-- Claims: which friend took which date
create table if not exists ww_claims (
  id uuid primary key default gen_random_uuid(),
  session_id uuid references ww_sessions(id) on delete cascade,
  date_iso text not null,
  friend_id uuid references ww_friends(id) on delete cascade,
  friend_name text not null,
  created_at timestamptz default now(),
  unique(session_id, date_iso)  -- one claim per date
);

-- Enable real-time on claims table (so host board updates instantly)
alter publication supabase_realtime add table ww_claims;
alter publication supabase_realtime add table ww_friends;

-- Allow public read/write (no auth needed for MVP)
alter table ww_sessions enable row level security;
alter table ww_dates enable row level security;
alter table ww_friends enable row level security;
alter table ww_claims enable row level security;

create policy "public_all" on ww_sessions for all using (true) with check (true);
create policy "public_all" on ww_dates for all using (true) with check (true);
create policy "public_all" on ww_friends for all using (true) with check (true);
create policy "public_all" on ww_claims for all using (true) with check (true);

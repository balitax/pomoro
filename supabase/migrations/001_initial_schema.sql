-- ============================================================
-- Pomoro — Initial Schema
-- Jalankan ini di Supabase Dashboard → SQL Editor
-- ============================================================

-- Extension UUID (biasanya sudah aktif di Supabase)
create extension if not exists "uuid-ossp";

-- ── Profiles ────────────────────────────────────────────────
-- Otomatis dibuat saat user sign in via Apple
create table if not exists public.profiles (
  id         uuid primary key references auth.users on delete cascade,
  created_at timestamptz not null default now()
);

-- Trigger: buat profil otomatis saat user baru sign in
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id)
  values (new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ── Pomodoro Tasks ───────────────────────────────────────────
create table if not exists public.pomodoro_tasks (
  id                   uuid        primary key default uuid_generate_v4(),
  user_id              uuid        not null references public.profiles(id) on delete cascade,
  title                text        not null,
  notes                text        not null default '',
  estimated_pomodoros  int         not null default 1,
  completed_pomodoros  int         not null default 0,
  is_completed         boolean     not null default false,
  is_today             boolean     not null default true,
  sort_order           int         not null default 0,
  created_at           timestamptz not null default now(),
  completed_at         timestamptz,
  updated_at           timestamptz not null default now()
);

-- Index untuk query cepat per user
create index if not exists idx_tasks_user_id    on public.pomodoro_tasks(user_id);
create index if not exists idx_tasks_is_today   on public.pomodoro_tasks(user_id, is_today);
create index if not exists idx_tasks_updated_at on public.pomodoro_tasks(user_id, updated_at desc);

-- Auto-update updated_at
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger tasks_updated_at
  before update on public.pomodoro_tasks
  for each row execute procedure public.set_updated_at();

-- ── Pomodoro Sessions ────────────────────────────────────────
create table if not exists public.pomodoro_sessions (
  id               uuid        primary key default uuid_generate_v4(),
  user_id          uuid        not null references public.profiles(id) on delete cascade,
  task_id          uuid        references public.pomodoro_tasks(id) on delete set null,
  session_type     text        not null check (session_type in ('focus', 'short_break', 'long_break')),
  duration         float8      not null,
  actual_duration  float8      not null default 0,
  was_completed    boolean     not null default false,
  started_at       timestamptz not null default now(),
  completed_at     timestamptz,
  updated_at       timestamptz not null default now()
);

create index if not exists idx_sessions_user_id    on public.pomodoro_sessions(user_id);
create index if not exists idx_sessions_started_at on public.pomodoro_sessions(user_id, started_at desc);
create index if not exists idx_sessions_task_id    on public.pomodoro_sessions(task_id);

create trigger sessions_updated_at
  before update on public.pomodoro_sessions
  for each row execute procedure public.set_updated_at();

-- ── Row Level Security ───────────────────────────────────────
-- Setiap user hanya bisa akses data miliknya sendiri

alter table public.profiles        enable row level security;
alter table public.pomodoro_tasks    enable row level security;
alter table public.pomodoro_sessions enable row level security;

-- Profiles
create policy "profiles: user can read own"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profiles: user can update own"
  on public.profiles for update
  using (auth.uid() = id);

-- Tasks: full CRUD untuk pemilik
create policy "tasks: select own"
  on public.pomodoro_tasks for select
  using (auth.uid() = user_id);

create policy "tasks: insert own"
  on public.pomodoro_tasks for insert
  with check (auth.uid() = user_id);

create policy "tasks: update own"
  on public.pomodoro_tasks for update
  using (auth.uid() = user_id);

create policy "tasks: delete own"
  on public.pomodoro_tasks for delete
  using (auth.uid() = user_id);

-- Sessions: full CRUD untuk pemilik
create policy "sessions: select own"
  on public.pomodoro_sessions for select
  using (auth.uid() = user_id);

create policy "sessions: insert own"
  on public.pomodoro_sessions for insert
  with check (auth.uid() = user_id);

create policy "sessions: update own"
  on public.pomodoro_sessions for update
  using (auth.uid() = user_id);

create policy "sessions: delete own"
  on public.pomodoro_sessions for delete
  using (auth.uid() = user_id);

-- ── Realtime ─────────────────────────────────────────────────
-- Aktifkan Realtime untuk kedua tabel
alter publication supabase_realtime add table public.pomodoro_tasks;
alter publication supabase_realtime add table public.pomodoro_sessions;

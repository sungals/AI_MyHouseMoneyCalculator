create table if not exists public.notices (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text not null,
  is_published boolean not null default false,
  published_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

alter table public.notices enable row level security;

drop policy if exists "Published notices are readable" on public.notices;
create policy "Published notices are readable"
on public.notices
for select
using (is_published = true);

alter publication supabase_realtime add table public.notices;

create index if not exists notices_published_at_idx
on public.notices (published_at desc)
where is_published = true;

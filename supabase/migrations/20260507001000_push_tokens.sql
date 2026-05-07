create table if not exists public.push_tokens (
  id uuid primary key default gen_random_uuid(),
  token text not null unique,
  platform text not null check (platform in ('android', 'ios', 'macos', 'web', 'unknown')),
  user_id uuid references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.push_tokens enable row level security;

drop policy if exists "Apps can register push tokens" on public.push_tokens;
create policy "Apps can register push tokens"
on public.push_tokens
for insert
with check (true);

drop policy if exists "Apps can refresh push tokens" on public.push_tokens;
create policy "Apps can refresh push tokens"
on public.push_tokens
for update
using (true)
with check (true);

drop policy if exists "Users can delete their push tokens" on public.push_tokens;
create policy "Users can delete their push tokens"
on public.push_tokens
for delete
using (user_id = auth.uid());

create index if not exists push_tokens_user_id_idx
on public.push_tokens (user_id);

create index if not exists push_tokens_updated_at_idx
on public.push_tokens (updated_at desc);

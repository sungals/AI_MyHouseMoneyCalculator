create table if not exists public.notice_reads (
  notice_id uuid not null references public.notices(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  read_at timestamptz not null default now(),
  primary key (notice_id, user_id)
);

alter table public.notice_reads enable row level security;

drop policy if exists "Users can read their notice read states" on public.notice_reads;
create policy "Users can read their notice read states"
on public.notice_reads
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "Users can mark notices as read" on public.notice_reads;
create policy "Users can mark notices as read"
on public.notice_reads
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "Users can refresh their notice read states" on public.notice_reads;
create policy "Users can refresh their notice read states"
on public.notice_reads
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create index if not exists notice_reads_user_id_idx
on public.notice_reads (user_id, read_at desc);

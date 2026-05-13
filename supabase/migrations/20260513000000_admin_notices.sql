alter table public.notices
add column if not exists content_html text;

alter table public.notices
add column if not exists updated_at timestamptz not null default now();

drop policy if exists "Admin can read all notices" on public.notices;
create policy "Admin can read all notices"
on public.notices
for select
to authenticated
using ((auth.jwt() ->> 'email') = 'sungals@gmail.com');

drop policy if exists "Admin can create notices" on public.notices;
create policy "Admin can create notices"
on public.notices
for insert
to authenticated
with check ((auth.jwt() ->> 'email') = 'sungals@gmail.com');

drop policy if exists "Admin can update notices" on public.notices;
create policy "Admin can update notices"
on public.notices
for update
to authenticated
using ((auth.jwt() ->> 'email') = 'sungals@gmail.com')
with check ((auth.jwt() ->> 'email') = 'sungals@gmail.com');

drop policy if exists "Admin can delete notices" on public.notices;
create policy "Admin can delete notices"
on public.notices
for delete
to authenticated
using ((auth.jwt() ->> 'email') = 'sungals@gmail.com');

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists notices_set_updated_at on public.notices;
create trigger notices_set_updated_at
before update on public.notices
for each row
execute function public.set_updated_at();

insert into storage.buckets (id, name, public)
values ('notice-images', 'notice-images', true)
on conflict (id) do update set public = true;

drop policy if exists "Public can read notice images" on storage.objects;
create policy "Public can read notice images"
on storage.objects
for select
using (bucket_id = 'notice-images');

drop policy if exists "Admin can upload notice images" on storage.objects;
create policy "Admin can upload notice images"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'notice-images'
  and (auth.jwt() ->> 'email') = 'sungals@gmail.com'
);

drop policy if exists "Admin can update notice images" on storage.objects;
create policy "Admin can update notice images"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'notice-images'
  and (auth.jwt() ->> 'email') = 'sungals@gmail.com'
)
with check (
  bucket_id = 'notice-images'
  and (auth.jwt() ->> 'email') = 'sungals@gmail.com'
);

drop policy if exists "Admin can delete notice images" on storage.objects;
create policy "Admin can delete notice images"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'notice-images'
  and (auth.jwt() ->> 'email') = 'sungals@gmail.com'
);

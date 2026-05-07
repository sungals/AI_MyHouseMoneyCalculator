delete from public.push_tokens
where user_id is null;

drop policy if exists "Apps can register push tokens" on public.push_tokens;
create policy "Authenticated users can register push tokens"
on public.push_tokens
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "Apps can refresh push tokens" on public.push_tokens;
create policy "Authenticated users can refresh their push tokens"
on public.push_tokens
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "Users can delete their push tokens" on public.push_tokens;
create policy "Users can delete their push tokens"
on public.push_tokens
for delete
to authenticated
using (user_id = auth.uid());

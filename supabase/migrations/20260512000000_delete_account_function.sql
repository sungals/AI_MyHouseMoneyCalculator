-- SECURITY DEFINER allows the function to run as postgres,
-- which has permission to delete from auth.users.
-- auth.uid() still resolves to the calling user's ID from their JWT.
create or replace function delete_account()
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  delete from public.calculation_history where user_id = auth.uid();
  delete from public.push_tokens         where user_id = auth.uid();
  delete from public.notice_reads        where user_id = auth.uid();
  delete from auth.users                 where id      = auth.uid();
end;
$$;

grant execute on function delete_account() to authenticated;

alter table if exists public.calculation_history
  add column if not exists memo text not null default '',
  add column if not exists is_favorite boolean not null default false,
  add column if not exists updated_at timestamptz not null default now(),
  add column if not exists deleted_at timestamptz;

create index if not exists calculation_history_user_updated_idx
  on public.calculation_history(user_id, updated_at desc);

create index if not exists calculation_history_user_favorite_idx
  on public.calculation_history(user_id, is_favorite)
  where is_favorite = true;

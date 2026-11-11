-- Experimental local-preproduction primitive. It is not a last-write-wins
-- resolver: changed, missing and deleted rows return a conflict without writes.
-- RLS and all existing table privileges run as the caller, not the function owner.
create function public.bicount_conditional_mutation(
  p_table text, p_id uuid, p_action text, p_expected jsonb, p_patch jsonb default null
) returns jsonb
language plpgsql security invoker set search_path = '' as $$
declare
  key_name text;
  current_row jsonb;
  changed_row jsonb;
  assignments text;
  invalid_columns integer;
begin
  if auth.uid() is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  key_name := case p_table
    when 'users' then 'uid'
    when 'friends' then 'sid'
    when 'transactions' then 'tid'
    when 'debts' then 'debt_id'
    when 'recurring_transfert' then 'recurring_transfert_id'
    else null
  end;
  if key_name is null or p_id is null or p_action is null or p_action not in ('update', 'delete')
     or jsonb_typeof(p_expected) is distinct from 'object'
     or p_expected ->> key_name is distinct from p_id::text then
    raise exception 'Invalid conditional mutation';
  end if;
  if p_action = 'update' and (
    jsonb_typeof(p_patch) is distinct from 'object' or
    p_patch - key_name = '{}'::jsonb or
    (p_patch ? key_name and p_patch ->> key_name is distinct from p_id::text)
  ) then
    raise exception 'Invalid conditional mutation patch';
  end if;
  execute format('select to_jsonb(t) from public.%I t where t.%I = $1 for update',
    p_table, key_name) into current_row using p_id;
  if current_row is null then
    return jsonb_build_object('status', 'conflict', 'row', current_row);
  end if;
  if current_row is distinct from p_expected then
    if p_action = 'update' and not exists (
      select 1 from jsonb_each(p_patch) e(key, value)
      where not (current_row ? e.key) or current_row -> e.key is distinct from e.value
    ) then
      return jsonb_build_object('status', 'already_applied', 'row', current_row);
    end if;
    return jsonb_build_object('status', 'conflict', 'row', current_row);
  end if;
  if p_action = 'delete' then
    execute format('delete from public.%I t where t.%I = $1 returning to_jsonb(t)',
      p_table, key_name) into changed_row using p_id;
  else
    select count(*) into invalid_columns
    from jsonb_object_keys(p_patch) k(name)
    where not exists (
      select 1 from pg_catalog.pg_attribute a
      where a.attrelid = format('public.%I', p_table)::regclass
        and a.attname = k.name and a.attnum > 0 and not a.attisdropped
        and a.attgenerated = '' and a.attidentity = ''
    );
    if invalid_columns > 0 then raise exception 'Unsupported patch column'; end if;
    select string_agg(format('%1$I = (jsonb_populate_record(t, $1)).%1$I', k.name), ', ')
      into assignments from jsonb_object_keys(p_patch) k(name) where k.name <> key_name;
    if assignments is null then raise exception 'Empty update patch'; end if;
    execute format('update public.%I t set %s where t.%I = $2 returning to_jsonb(t)',
      p_table, assignments, key_name) into changed_row using p_patch, p_id;
  end if;
  if changed_row is null then return jsonb_build_object('status', 'not_applied'); end if;
  return jsonb_build_object('status', 'applied', 'row', changed_row);
end;
$$;
revoke all on function public.bicount_conditional_mutation(text, uuid, text, jsonb, jsonb)
  from public, anon;
grant execute on function public.bicount_conditional_mutation(text, uuid, text, jsonb, jsonb)
  to authenticated;

-- =============================================================================
-- MatSafe Control V1 — 0008 · Supabase Storage (bucket privé + policies)
-- -----------------------------------------------------------------------------
-- Bucket privé : matsafe-attachments
-- Convention de chemin : {club_id}/{entity_type}/{entity_id}/{attachment_id}-{filename}
--   -> le 1er segment = club_id ; l'isolation inter-clubs repose dessus.
-- storage.foldername(name)[1] = club_id, contrôlé par is_club_member().
-- =============================================================================

insert into storage.buckets (id, name, public)
values ('matsafe-attachments', 'matsafe-attachments', false)
on conflict (id) do nothing;

-- Lecture : membre du club (1er segment) ou admin
create policy matsafe_attachments_select on storage.objects
  for select to authenticated
  using (
    bucket_id = 'matsafe-attachments'
    and (
      public.is_platform_admin()
      or public.is_club_member((storage.foldername(name))[1]::uuid)
    )
  );

-- Upload : membre du club (1er segment) ou admin
create policy matsafe_attachments_insert on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'matsafe-attachments'
    and (
      public.is_platform_admin()
      or public.is_club_member((storage.foldername(name))[1]::uuid)
    )
  );

-- Suppression : direction / référent hygiène du club, ou admin
create policy matsafe_attachments_delete on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'matsafe-attachments'
    and (
      public.is_platform_admin()
      or public.has_club_role((storage.foldername(name))[1]::uuid,
                              'club_direction', 'hygiene_referent')
    )
  );

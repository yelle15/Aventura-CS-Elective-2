drop policy if exists "Products can be inserted" on public.products;
create policy "Products can be inserted"
  on public.products for insert
  to authenticated
  with check (true);

drop policy if exists "Products can be updated" on public.products;
create policy "Products can be updated"
  on public.products for update
  to authenticated
  using (true)
  with check (true);

drop policy if exists "Products can be deleted" on public.products;
create policy "Products can be deleted"
  on public.products for delete
  to authenticated
  using (true);

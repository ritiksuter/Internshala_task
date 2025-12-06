-- LearnLynk Tech Test - Task 2: RLS Policies on leads

alter table public.leads enable row level security;

-- Example helper: assume JWT has tenant_id, user_id, role.
-- You can use: current_setting('request.jwt.claims', true)::jsonb

-- TODO: write a policy so:
-- - counselors see leads where they are owner_id OR in one of their teams
-- - admins can see all leads of their tenant


-- Example skeleton for SELECT (replace with your own logic):


create policy "leads_select_policy"
on public.leads
for select
using (
  (
    -- Admins: can see all leads in their tenant
    current_setting('request.jwt.claims.role', true) = 'admin'
    AND tenant_id = current_setting('request.jwt.claims.tenant_id', true)::uuid
  )
  OR
  (
    -- Counselors: see leads they own
    current_setting('request.jwt.claims.role', true) = 'counselor'
    AND owner_id = current_setting('request.jwt.claims.user_id', true)::uuid
  )
  OR
  (
    -- Counselors: see leads assigned to a team they belong to
    current_setting('request.jwt.claims.role', true) = 'counselor'
    AND EXISTS (
      SELECT 1
      FROM public.user_teams ut
      WHERE ut.user_id = current_setting('request.jwt.claims.user_id', true)::uuid
        AND ut.team_id = public.leads.team_id
    )
  )
);

-- TODO: add INSERT policy that:
-- - allows counselors/admins to insert leads for their tenant
-- - ensures tenant_id is correctly set/validated
create policy "leads_insert_policy"
on public.leads
for insert
with check (
  (
    current_setting('request.jwt.claims.role', true) IN ('admin','counselor')
  )
  AND
  tenant_id = current_setting('request.jwt.claims.tenant_id', true)::uuid
);
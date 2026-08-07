-- 1. Enums for Moderation and Audit
create type report_entity_type as enum ('user', 'post', 'comment', 'group', 'event', 'image', 'video', 'message');
create type report_status_type as enum ('pending', 'in_review', 'resolved', 'dismissed');

-- 2. RBAC: Permissions
create table public.permissions (
  id uuid primary key default gen_random_uuid(),
  name text unique not null,
  description text
);

-- Insert core permissions
insert into public.permissions (name) values
('manage_users'), ('manage_groups'), ('manage_events'),
('manage_reports'), ('manage_posts'), ('manage_comments'),
('manage_media'), ('manage_music'), ('manage_ads'),
('manage_roles'), ('manage_settings'), ('manage_database');

-- 3. RBAC: Roles
create table public.roles (
  id uuid primary key default gen_random_uuid(),
  name text unique not null,
  description text
);

-- Insert core roles
insert into public.roles (name) values
('Super Admin'), ('Admin'), ('Global Moderator'),
('Community Moderator'), ('Support'), ('Verified User'), ('Standard User');

-- 4. RBAC: Role Permissions
create table public.role_permissions (
  role_id uuid references public.roles(id) on delete cascade not null,
  permission_id uuid references public.permissions(id) on delete cascade not null,
  primary key (role_id, permission_id)
);

-- (In a real scenario, we would seed the specific mappings here. Ex: Super Admin gets all)

-- 5. RBAC: User Roles
create table public.user_roles (
  user_id uuid references public.profiles(id) on delete cascade not null,
  role_id uuid references public.roles(id) on delete cascade not null,
  assigned_at timestamp with time zone default now() not null,
  assigned_by uuid references public.profiles(id) on delete set null,
  primary key (user_id, role_id)
);
create index idx_user_roles_user on public.user_roles(user_id);

-- Helper function to check permissions securely in RLS
create or replace function public.has_permission(required_permission text)
returns boolean
language sql security definer
as $$
  select exists (
    select 1
    from public.user_roles ur
    join public.role_permissions rp on ur.role_id = rp.role_id
    join public.permissions p on rp.permission_id = p.id
    where ur.user_id = auth.uid() and p.name = required_permission
  );
$$;

-- Secure RBAC tables (Only admins with manage_roles can change them, anyone can read their own)
alter table public.roles enable row level security;
alter table public.permissions enable row level security;
alter table public.role_permissions enable row level security;
alter table public.user_roles enable row level security;

create policy "Roles viewable by all" on public.roles for select using (true);
create policy "Permissions viewable by all" on public.permissions for select using (true);
create policy "Role permissions viewable by all" on public.role_permissions for select using (true);

create policy "Users can view their roles" on public.user_roles for select using (auth.uid() = user_id or public.has_permission('manage_roles'));
create policy "Admins can assign roles" on public.user_roles for insert with check (public.has_permission('manage_roles'));
create policy "Admins can remove roles" on public.user_roles for delete using (public.has_permission('manage_roles'));


-- 6. Reports System
create table public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid references public.profiles(id) on delete set null,
  entity_type report_entity_type not null,
  entity_id uuid not null, -- Can point to posts, users, comments, etc.
  reason text not null,
  status report_status_type default 'pending' not null,
  notes text, -- For moderators
  resolved_by uuid references public.profiles(id) on delete set null,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null
);
create index idx_reports_status on public.reports(status);
create index idx_reports_entity on public.reports(entity_type, entity_id);

alter table public.reports enable row level security;
-- Anyone can create a report, only mods can view/update them
create policy "Users can create reports" on public.reports for insert with check (auth.uid() = reporter_id);
create policy "Moderators can view reports" on public.reports for select using (public.has_permission('manage_reports') or auth.uid() = reporter_id);
create policy "Moderators can update reports" on public.reports for update using (public.has_permission('manage_reports'));

-- 7. Audit Logs
create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  admin_id uuid references public.profiles(id) on delete set null,
  action text not null, -- e.g., 'ban_user', 'delete_post', 'assign_role'
  resource_type text not null,
  resource_id uuid,
  details jsonb, -- Capture what changed
  ip_address text,
  created_at timestamp with time zone default now() not null
);
create index idx_audit_logs_admin on public.audit_logs(admin_id);
create index idx_audit_logs_created on public.audit_logs(created_at desc);

alter table public.audit_logs enable row level security;
-- Append only, and only viewable by high level admins
create policy "Insert audit logs" on public.audit_logs for insert with check (auth.uid() = admin_id);
create policy "Super Admins can view audit logs" on public.audit_logs for select using (public.has_permission('manage_database') or public.has_permission('manage_roles'));

-- 8. Saved Items (Bookmarks)
-- Using a generic approach to allow saving posts, events, groups, etc.
create table public.saved_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  collection_name text default 'General' not null,
  item_type text not null, -- 'post', 'event', etc.
  item_id uuid not null,
  created_at timestamp with time zone default now() not null,
  unique(user_id, item_type, item_id)
);
create index idx_saved_items_user on public.saved_items(user_id, collection_name);

alter table public.saved_items enable row level security;
create policy "Users can manage their saved items" on public.saved_items for all using (auth.uid() = user_id);

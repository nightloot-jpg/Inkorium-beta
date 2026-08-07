-- 1. Enums for Groups and Events
create type group_privacy_type as enum ('public', 'private', 'secret');
create type group_role_type as enum ('owner', 'admin', 'moderator', 'member');
create type group_member_status_type as enum ('pending', 'accepted', 'banned');

create type event_type as enum ('physical', 'online', 'hybrid');
create type event_privacy_type as enum ('public', 'friends_only', 'private', 'group_only');
create type event_rsvp_status as enum ('going', 'maybe', 'declined', 'invited');

-- 2. Categories Table (For long term scalability of Marketplace/Universities/etc)
create table public.categories (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  description text,
  icon_url text,
  parent_id uuid references public.categories(id)
);

-- 3. Groups Table
create table public.groups (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid references public.profiles(id) not null,
  category_id uuid references public.categories(id),
  chat_channel_id uuid references public.chat_channels(id) on delete set null,
  name text not null,
  slug text unique not null,
  description text,
  rules text,
  avatar_url text,
  banner_url text,
  privacy_level group_privacy_type default 'public' not null,
  member_count int default 0 not null,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null
);

create index idx_groups_slug on public.groups(slug);
create index idx_groups_category on public.groups(category_id);
create index idx_groups_privacy on public.groups(privacy_level);

alter table public.groups enable row level security;
-- RLS for Groups: Secret groups are only visible to members
create policy "Select groups" on public.groups for select
using (
  privacy_level != 'secret'
  or exists (select 1 from public.group_members where group_id = id and user_id = auth.uid() and status = 'accepted')
);
create policy "Insert groups" on public.groups for insert with check (auth.uid() = creator_id);


-- 4. Group Members
create table public.group_members (
  group_id uuid references public.groups(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  role group_role_type default 'member' not null,
  status group_member_status_type default 'accepted' not null,
  joined_at timestamp with time zone default now() not null,
  primary key (group_id, user_id)
);

create index idx_group_members_user on public.group_members(user_id);

alter table public.group_members enable row level security;
create policy "Select group members" on public.group_members for select
using (exists (select 1 from public.groups where id = group_id)); -- Follows group visibility

-- 5. Events Table
create table public.events (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid references public.profiles(id) not null,
  group_id uuid references public.groups(id) on delete cascade,
  chat_channel_id uuid references public.chat_channels(id) on delete set null,
  name text not null,
  description text,
  cover_url text,
  type event_type default 'physical' not null,
  location_name text,
  location_lat double precision,
  location_lng double precision,
  online_url text,
  start_time timestamp with time zone not null,
  end_time timestamp with time zone,
  attendee_limit int,
  privacy_level event_privacy_type default 'public' not null,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null
);

create index idx_events_group on public.events(group_id);
create index idx_events_start on public.events(start_time);

alter table public.events enable row level security;
-- Simplified RLS: If group event, relies on group RLS. If personal, relies on friend status.
create policy "Select events" on public.events for select
using (
  privacy_level = 'public'
  or creator_id = auth.uid()
  or (privacy_level = 'group_only' and exists (select 1 from public.group_members where group_id = events.group_id and user_id = auth.uid() and status = 'accepted'))
  or (privacy_level = 'friends_only' and exists (
      select 1 from public.friendships
      where status = 'accepted'
      and ((requester_id = auth.uid() and addressee_id = events.creator_id) or (addressee_id = auth.uid() and requester_id = events.creator_id))
  ))
);

-- 6. Event Attendees
create table public.event_attendees (
  event_id uuid references public.events(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  status event_rsvp_status default 'going' not null,
  created_at timestamp with time zone default now() not null,
  primary key (event_id, user_id)
);
create index idx_event_attendees_user on public.event_attendees(user_id);
alter table public.event_attendees enable row level security;
create policy "Select event attendees" on public.event_attendees for select using (exists (select 1 from public.events where id = event_id));

-- 7. Update Posts Table to support Groups
alter table public.posts
add column group_id uuid references public.groups(id) on delete cascade;
create index idx_posts_group_id on public.posts(group_id);

-- Need to update Posts RLS to allow viewing group posts if user has access to group
drop policy "Select posts" on public.posts;
create policy "Select posts" on public.posts for select
using (
  auth.uid() = author_id
  or (group_id is null and visibility = 'public')
  or (group_id is null and visibility = 'friends_only' and exists (
      select 1 from public.friendships
      where status = 'accepted'
      and ((requester_id = auth.uid() and addressee_id = posts.author_id) or (addressee_id = auth.uid() and requester_id = posts.author_id))
    ))
  or (group_id is not null and exists (
      select 1 from public.groups g
      left join public.group_members gm on g.id = gm.group_id and gm.user_id = auth.uid()
      where g.id = posts.group_id
      and (g.privacy_level != 'secret' or (gm.status = 'accepted'))
  ))
);

-- 8. Auto-create chat channel trigger for Groups
create or replace function public.handle_new_group()
returns trigger
language plpgsql security definer
as $$
declare
  new_channel_id uuid;
begin
  -- Create chat channel
  insert into public.chat_channels (type, name) values ('community', new.name) returning id into new_channel_id;
  -- Update group with channel
  update public.groups set chat_channel_id = new_channel_id where id = new.id;
  -- Add creator as admin
  insert into public.chat_participants (channel_id, user_id, role) values (new_channel_id, new.creator_id, 'admin');
  -- Add creator to group members
  insert into public.group_members (group_id, user_id, role, status) values (new.id, new.creator_id, 'owner', 'accepted');
  return new;
end;
$$;
create trigger on_group_created
  after insert on public.groups
  for each row execute procedure public.handle_new_group();

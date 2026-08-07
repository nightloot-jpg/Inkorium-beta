-- 1. Create Enums for Profile and Relationships
create type profile_visibility_type as enum ('public', 'friends', 'private');
create type permission_level_type as enum ('everyone', 'friends', 'nobody');
create type friendship_status_type as enum ('pending', 'accepted', 'rejected');

-- 2. Update Profiles Table
alter table public.profiles
add column banner_url text,
add column bio text,
add column city text,
add column birth_date date,
add column user_status text,
add column visibility profile_visibility_type default 'public';

-- 3. Create Privacy Settings Table
create table public.privacy_settings (
  user_id uuid references public.profiles(id) on delete cascade primary key,
  who_can_friend permission_level_type default 'everyone',
  who_can_follow permission_level_type default 'everyone',
  who_can_message permission_level_type default 'everyone',
  who_can_comment permission_level_type default 'everyone',
  who_can_tag permission_level_type default 'everyone',
  updated_at timestamp with time zone default now()
);
alter table public.privacy_settings enable row level security;

create policy "Users can view their own settings" on privacy_settings for select using (auth.uid() = user_id);
create policy "Users can update their own settings" on privacy_settings for update using (auth.uid() = user_id);

-- Trigger to create privacy settings when a profile is created
create or replace function public.handle_new_privacy_settings()
returns trigger
language plpgsql security definer
as $$
begin
  insert into public.privacy_settings (user_id) values (new.id);
  return new;
end;
$$;
create trigger on_profile_created
  after insert on public.profiles
  for each row execute procedure public.handle_new_privacy_settings();

-- 4. Create Friendships Table (Bidirectional Logic)
create table public.friendships (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid references public.profiles(id) on delete cascade not null,
  addressee_id uuid references public.profiles(id) on delete cascade not null,
  status friendship_status_type default 'pending' not null,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  unique(requester_id, addressee_id),
  constraint cant_friend_self check (requester_id != addressee_id)
);
alter table public.friendships enable row level security;

create policy "Users can see friendships they are part of"
on friendships for select
using (auth.uid() = requester_id or auth.uid() = addressee_id);

create policy "Users can insert friendship requests"
on friendships for insert
with check (auth.uid() = requester_id);

create policy "Users can update friendships they are part of (accept/reject)"
on friendships for update
using (auth.uid() = addressee_id);

-- 5. Create Follows Table (Unidirectional)
create table public.follows (
  follower_id uuid references public.profiles(id) on delete cascade not null,
  following_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default now(),
  primary key (follower_id, following_id),
  constraint cant_follow_self check (follower_id != following_id)
);
alter table public.follows enable row level security;

create policy "Follows are viewable by everyone" on follows for select using (true);
create policy "Users can follow others" on follows for insert with check (auth.uid() = follower_id);
create policy "Users can unfollow" on follows for delete using (auth.uid() = follower_id);

-- 6. Create Blocks Table
create table public.blocks (
  blocker_id uuid references public.profiles(id) on delete cascade not null,
  blocked_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default now(),
  primary key (blocker_id, blocked_id),
  constraint cant_block_self check (blocker_id != blocked_id)
);
alter table public.blocks enable row level security;

create policy "Users can see who they blocked" on blocks for select using (auth.uid() = blocker_id);
create policy "Users can block others" on blocks for insert with check (auth.uid() = blocker_id);
create policy "Users can unblock others" on blocks for delete using (auth.uid() = blocker_id);

-- Add logic to Profiles RLS to hide blocked users (Optional for later, but good base)
-- We will handle complex blocked visibility in application logic/API to prevent recursive policy issues.

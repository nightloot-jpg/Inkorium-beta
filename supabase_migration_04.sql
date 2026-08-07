-- 1. Enums for Chat and Notifications
create type chat_channel_type as enum ('direct', 'group', 'community');
create type message_type as enum ('text', 'image', 'video', 'audio', 'document', 'location', 'sticker');
create type notification_type as enum (
  'like', 'comment', 'reply', 'friend_request', 'friend_accept',
  'follow', 'message', 'event_invite', 'mention', 'tag', 'share'
);

-- 2. Chat Channels
create table public.chat_channels (
  id uuid primary key default gen_random_uuid(),
  type chat_channel_type default 'direct' not null,
  name text, -- Nullable, mainly for groups/communities
  description text,
  avatar_url text,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null
);

-- 3. Chat Participants
create table public.chat_participants (
  channel_id uuid references public.chat_channels(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  role text default 'member' not null, -- 'admin', 'member'
  last_read_message_id uuid, -- Will be a FK to messages, created later to avoid circular dependency initially
  joined_at timestamp with time zone default now() not null,
  primary key (channel_id, user_id)
);
create index idx_chat_parts_user_id on public.chat_participants(user_id);

alter table public.chat_channels enable row level security;
alter table public.chat_participants enable row level security;

create policy "Users can view channels they participate in" on public.chat_channels for select
using (exists (select 1 from public.chat_participants where channel_id = id and user_id = auth.uid()));

create policy "Users can see participants of their channels" on public.chat_participants for select
using (exists (select 1 from public.chat_participants cp where cp.channel_id = chat_participants.channel_id and cp.user_id = auth.uid()));

-- 4. Chat Messages
create table public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  channel_id uuid references public.chat_channels(id) on delete cascade not null,
  sender_id uuid references public.profiles(id) on delete cascade not null,
  type message_type default 'text' not null,
  content text, -- Text or JSON payload for rich content/metadata (URLs, coordinates, etc)
  reply_to_id uuid references public.chat_messages(id) on delete set null,
  is_edited boolean default false,
  is_deleted boolean default false, -- Soft delete
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null
);

create index idx_messages_channel_created on public.chat_messages(channel_id, created_at desc);

alter table public.chat_messages enable row level security;
create policy "Users can view messages in their channels" on public.chat_messages for select
using (exists (select 1 from public.chat_participants where channel_id = chat_messages.channel_id and user_id = auth.uid()));

create policy "Users can send messages to their channels" on public.chat_messages for insert
with check (exists (select 1 from public.chat_participants where channel_id = chat_messages.channel_id and user_id = auth.uid()) and auth.uid() = sender_id);

create policy "Users can edit their own messages" on public.chat_messages for update
using (auth.uid() = sender_id);

-- 5. Notifications
create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade not null, -- The receiver
  actor_id uuid references public.profiles(id) on delete cascade not null, -- Who triggered it
  type notification_type not null,
  entity_id uuid, -- The ID of the post, comment, friend request etc.
  is_read boolean default false not null,
  created_at timestamp with time zone default now() not null
);

create index idx_notifs_user_read on public.notifications(user_id, is_read);
create index idx_notifs_user_created on public.notifications(user_id, created_at desc);

alter table public.notifications enable row level security;
create policy "Users can view their own notifications" on public.notifications for select using (auth.uid() = user_id);
create policy "Users can update their own notifications (read)" on public.notifications for update using (auth.uid() = user_id);

-- 6. Supabase Realtime Publication
-- Add tables to realtime publication to broadcast changes to subscribed clients
alter publication supabase_realtime add table public.chat_messages;
alter publication supabase_realtime add table public.notifications;

-- 7. Triggers for Automatic Notifications

-- A) Trigger for Friend Requests
create or replace function public.notify_friend_request()
returns trigger
language plpgsql security definer
as $$
begin
  if (tg_op = 'INSERT' and new.status = 'pending') then
    insert into public.notifications (user_id, actor_id, type, entity_id)
    values (new.addressee_id, new.requester_id, 'friend_request', new.id);
  elsif (tg_op = 'UPDATE' and old.status = 'pending' and new.status = 'accepted') then
    insert into public.notifications (user_id, actor_id, type, entity_id)
    values (new.requester_id, new.addressee_id, 'friend_accept', new.id);
  end if;
  return new;
end;
$$;
create trigger on_friendship_change
  after insert or update on public.friendships
  for each row execute procedure public.notify_friend_request();

-- B) Trigger for Post Likes
create or replace function public.notify_post_like()
returns trigger
language plpgsql security definer
as $$
declare
  post_author_id uuid;
begin
  select author_id into post_author_id from public.posts where id = new.post_id;

  -- Don't notify if the user liked their own post
  if (post_author_id != new.user_id) then
    insert into public.notifications (user_id, actor_id, type, entity_id)
    values (post_author_id, new.user_id, 'like', new.post_id);
  end if;
  return new;
end;
$$;
create trigger on_post_like
  after insert on public.post_likes
  for each row execute procedure public.notify_post_like();

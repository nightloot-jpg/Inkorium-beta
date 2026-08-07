-- 1. Enums
create type post_visibility_type as enum ('public', 'friends_only', 'private');

-- 2. Core Posts Table
create table public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references public.profiles(id) on delete cascade not null,
  content text,
  visibility post_visibility_type default 'public' not null,
  shared_post_id uuid references public.posts(id) on delete set null,
  is_edited boolean default false,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null
);

-- Indexes for scaling the feed
create index idx_posts_author_id on public.posts(author_id);
create index idx_posts_created_at on public.posts(created_at desc);
create index idx_posts_visibility on public.posts(visibility);
create index idx_posts_shared_post on public.posts(shared_post_id);

-- RLS for Posts
alter table public.posts enable row level security;

-- A user can see a post if:
-- 1. They wrote it
-- 2. It is public
-- 3. It is friends_only AND they are accepted friends with the author
create policy "Select posts" on public.posts for select
using (
  auth.uid() = author_id
  or visibility = 'public'
  or (
    visibility = 'friends_only' and exists (
      select 1 from public.friendships
      where status = 'accepted'
      and (
        (requester_id = auth.uid() and addressee_id = posts.author_id)
        or
        (addressee_id = auth.uid() and requester_id = posts.author_id)
      )
    )
  )
);

create policy "Insert posts" on public.posts for insert with check (auth.uid() = author_id);
create policy "Update posts" on public.posts for update using (auth.uid() = author_id);
create policy "Delete posts" on public.posts for delete using (auth.uid() = author_id);

-- 3. Comments Table (Supports 1 level nesting)
create table public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references public.posts(id) on delete cascade not null,
  author_id uuid references public.profiles(id) on delete cascade not null,
  parent_comment_id uuid references public.comments(id) on delete cascade,
  content text not null,
  is_edited boolean default false,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null
);

create index idx_comments_post_id on public.comments(post_id);
create index idx_comments_parent on public.comments(parent_comment_id);
create index idx_comments_created_at on public.comments(created_at desc);

alter table public.comments enable row level security;
-- Visibility cascades from posts (if you can see the post, you can see comments)
create policy "Select comments" on public.comments for select
using (exists (select 1 from public.posts where id = comments.post_id));
create policy "Insert comments" on public.comments for insert with check (auth.uid() = author_id);
create policy "Update comments" on public.comments for update using (auth.uid() = author_id);
create policy "Delete comments" on public.comments for delete using (auth.uid() = author_id);

-- 4. Post Attachments (Images, Videos)
create table public.post_images (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references public.posts(id) on delete cascade not null,
  storage_path text not null,
  alt_text text,
  display_order int default 0 not null,
  created_at timestamp with time zone default now() not null
);
create index idx_post_images_post_id on public.post_images(post_id);

create table public.post_videos (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references public.posts(id) on delete cascade not null,
  storage_path text not null,
  thumbnail_path text,
  duration_seconds int,
  created_at timestamp with time zone default now() not null
);
create index idx_post_videos_post_id on public.post_videos(post_id);

-- We enable RLS on attachments based on post visibility
alter table public.post_images enable row level security;
create policy "Select post images" on public.post_images for select using (exists (select 1 from public.posts where id = post_images.post_id));
create policy "Insert post images" on public.post_images for insert with check (exists (select 1 from public.posts where id = post_images.post_id and author_id = auth.uid()));

alter table public.post_videos enable row level security;
create policy "Select post videos" on public.post_videos for select using (exists (select 1 from public.posts where id = post_videos.post_id));
create policy "Insert post videos" on public.post_videos for insert with check (exists (select 1 from public.posts where id = post_videos.post_id and author_id = auth.uid()));


-- 5. Reactions
create table public.post_likes (
  user_id uuid references public.profiles(id) on delete cascade not null,
  post_id uuid references public.posts(id) on delete cascade not null,
  created_at timestamp with time zone default now() not null,
  primary key (user_id, post_id)
);
create index idx_post_likes_post_id on public.post_likes(post_id);

alter table public.post_likes enable row level security;
create policy "Select post likes" on public.post_likes for select using (exists (select 1 from public.posts where id = post_likes.post_id));
create policy "Insert post likes" on public.post_likes for insert with check (auth.uid() = user_id);
create policy "Delete post likes" on public.post_likes for delete using (auth.uid() = user_id);

create table public.comment_likes (
  user_id uuid references public.profiles(id) on delete cascade not null,
  comment_id uuid references public.comments(id) on delete cascade not null,
  created_at timestamp with time zone default now() not null,
  primary key (user_id, comment_id)
);
create index idx_comment_likes_comment_id on public.comment_likes(comment_id);

alter table public.comment_likes enable row level security;
create policy "Select comment likes" on public.comment_likes for select using (exists (select 1 from public.comments where id = comment_likes.comment_id));
create policy "Insert comment likes" on public.comment_likes for insert with check (auth.uid() = user_id);
create policy "Delete comment likes" on public.comment_likes for delete using (auth.uid() = user_id);

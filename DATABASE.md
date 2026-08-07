# Inkorium - Database Architecture

## Core Principles

1. **Security First**: Row Level Security (RLS) handles all permissions directly at the database layer (Public, Friends-only, Private).
2. **Strict Foreign Keys**: No polymorphic tables for core relationships to maintain data integrity.
3. **Scalable Content**: `posts` is the primary container for all feed activity. Media and rich content (images, videos, polls) are stored in separate related tables.
4. **Performance**: Indexes on high-cardinality columns (e.g., `user_id`, `created_at`, `status`) to support millions of rows.

## Schema Overview

### 1. Users & Relationships (Phase 2 & 3)

- `profiles`: Core user data (avatar, bio, visibility).
- `privacy_settings`: Granular controls (who can friend, message, tag).
- `friendships`: Bidirectional relationships (`pending`, `accepted`, `rejected`).
- `follows`: Unidirectional following system.
- `blocks`: Blocks between users.

### 2. Feed & Content (Phase 4)

- `posts`: The universal container for feed items.
  - Supports text content, visibility rules, and sharing (`shared_post_id`).
- **Post Attachments (1:N or 1:1 with posts)**:
  - `post_images`: URLs and metadata for images.
  - `post_videos`: Video URLs/processing states.
  - `post_audio`: Music/voice notes.
  - `post_polls` & `post_poll_options`: Interactive polls.
  - `post_events`: Event invitations in the feed.
- `comments`: Nested discussions under posts. Supports one level of nesting via `parent_comment_id`.

### 3. Interactions

- `post_likes`: User interactions on posts.
- `comment_likes`: User interactions on comments.

## RLS Security Model (Posts)

A user can view a post if:

1. They are the author.
2. The post visibility is `public`.
3. The post visibility is `friends_only` AND an `accepted` record exists in `friendships` between the viewer and the author.

## Indexing Strategy

- Primary keys automatically indexed.
- Foreign keys (`user_id`, `post_id`) indexed for fast JOINs.
- `created_at` indexed in descending order for rapid feed generation.
- Compound indexes for relationships (e.g., `(requester_id, addressee_id, status)`).

### 4. Real-Time (Chat & Notifications) (Phase 5)

- `chat_channels`: Manages private, group, and community chats.
- `chat_participants`: Users in a channel with `last_read_message_id`.
- `chat_messages`: Supports rich content (images, audio, location), replies (`reply_to_id`), edits, and soft deletes.
- `chat_reactions`: Reactions specific to messages.
- `notifications`: Unified notification table. Uses PostgreSQL Triggers to automatically generate notifications for likes, comments, friend requests, etc.

## Indexing Strategy (Real-Time)

- `chat_messages(channel_id, created_at desc)`: For fast initial load of chat history.
- `notifications(user_id, is_read, created_at desc)`: Optimized for fetching unread notifications.

### 5. Communities & Events (Phase 6)

- `groups`: Universal container for communities, clubs, companies, etc. (`type`, `privacy`, `category_id`).
- `group_members`: Manages membership and RBAC (`owner`, `admin`, `moderator`, `member`).
- `events`: Events management, supporting physical/online venues, linked to groups or individual profiles.
- `event_attendees`: RSVP statuses.
- **Integration**:
  - `posts.group_id`: Links posts to groups for unified feed capability.
  - `groups.chat_channel_id` & `events.chat_channel_id`: Automatically bridges communities to real-time chat.

### 6. Global Administration & RBAC (Phase 7)

- **Role-Based Access Control (RBAC)**:
  - `roles`: Defines global roles (Super Admin, Moderator, etc.).
  - `permissions`: Atomic actions (`manage_users`, `manage_reports`).
  - `role_permissions`: Links roles to permissions.
  - `user_roles`: Assigns roles to users.
- **Moderation**:
  - `reports`: Generic reporting system (`entity_type`, `entity_id`) to flag content across any module.
  - `audit_logs`: Tracks administrative actions for accountability.
- **Bookmarks**:
  - `saved_items`: Polymorphic saving system (posts, events) organized into collections.

## Next Steps / Future Enhancements

- See `ROADMAP.md` for the technical backlog and upcoming features.

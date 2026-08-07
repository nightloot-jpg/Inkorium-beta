# Inkorium - Technical Architecture Report

Generated on: 2026-08-07

## 1. Executive Summary

Inkorium is a highly scalable, real-time social network built using modern SSR technologies and a strictly typed PostgreSQL database. The system is designed to handle millions of concurrent users by leveraging Row Level Security (RLS) and database triggers, ensuring security and performance at the lowest level.

## 2. Technology Stack

- **Frontend/SSR**: React 19, TanStack Start, TanStack Router, TanStack Query.
- **Styling**: Tailwind CSS v4, shadcn/ui.
- **Backend/Database**: Supabase (PostgreSQL 17), Supabase Auth, Supabase Realtime.
- **Deployment**: Nitro (Node Server preset), Docker, Coolify.

## 3. Directory Structure

```
src/
├── components/   # Shared UI components (shadcn)
├── context/      # React Contexts
├── features/     # Domain-driven feature modules
│   ├── admin/    # Dashboard, Logs, Moderation UI
│   ├── auth/     # Login, Register
│   ├── chat/     # Realtime chat channels UI
│   ├── feed/     # Posts, Comments, Attachments UI
│   ├── groups/   # Communities and Events UI
│   └── profile/  # User profiles UI
├── hooks/        # Custom React Hooks
├── lib/          # Utilities (Supabase client, cn)
├── routes/       # File-based routing (TanStack Router)
├── server/       # Server-only functions and SSR clients
├── store/        # Global state management
├── types/        # TypeScript interfaces
└── utils/        # Helper functions
```

## 4. Database Architecture Overview

The database strictly follows a relational model without polymorphic core relationships.

### Implemented Modules:

1. **Auth & Profiles**: `profiles` (1:1 with auth.users).
2. **Relationships**: `friendships` (bidirectional), `follows` (unidirectional), `blocks`.
3. **Privacy**: `privacy_settings` (1:1 with profiles).
4. **Content**: `posts` (Core container), `comments`.
5. **Media**: `post_images`, `post_videos`.
6. **Reactions**: `post_likes`, `comment_likes`.
7. **Real-Time**: `chat_channels`, `chat_participants`, `chat_messages`, `notifications`.
8. **Communities**: `groups`, `group_members`, `categories`.
9. **Events**: `events`, `event_attendees`.
10. **Administration**: `roles`, `permissions`, `role_permissions`, `user_roles`.
11. **Moderation**: `reports`, `audit_logs`.
12. **Saves**: `saved_items`.

### Key Technical Decisions:

- **Triggers**: `notifications` and `chat_channels` (for groups) are generated automatically via PL/pgSQL triggers to guarantee atomicity.
- **RLS**: The feed logic validates friendship status directly inside the `SELECT` policy.

## 5. Technical Debt & Known Limitations

- _File Uploads_: Currently, UI components simulate media. Integration with Supabase Storage buckets (policies, resumable uploads) is required for the `post_images` to function.
- _Real-time Subscriptions_: `supabase.channel()` logic needs to be implemented in `src/hooks` to actively listen to the `notifications` and `chat_messages` tables.
- _Pagination_: TanStack Query infinite query hooks need to be wired up for the feed to handle millions of posts.

## 6. Future Enhancements (Phase 8+)

- **Marketplace & E-commerce**: Using the `categories` architecture.
- **End-to-End Encryption (E2EE)**: For private `chat_channels`.
- **Advanced Moderation**: AI-powered auto-flagging in edge functions before inserting to `reports`.

---

_End of Report_

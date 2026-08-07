# Inkorium - Project Roadmap

## Phase 1: Infrastructure (Completed)

- [x] Initial setup (React 19, TanStack Start/Router/Query, Tailwind v4, shadcn).
- [x] Dockerfile for Coolify deployment.

## Phase 2: Auth & Database (Completed)

- [x] Supabase integration.
- [x] Public profiles base table.
- [x] Login and Registration SSR pages.

## Phase 3: Core Social (Completed)

- [x] Bidirectional friend system (`friendships`).
- [x] Unidirectional follow system (`follows`).
- [x] Blocking and granular privacy settings.
- [x] Profile UI.

## Phase 4: Feed & Content (Completed)

- [x] Unified `posts` table for all feed items.
- [x] Rich attachments (`post_images`, `post_videos`).
- [x] Comments (1 level deep) and Likes.
- [x] Database Architecture Document (DATABASE.md).

## Phase 5: Real-Time (Completed)

- [x] Channel-based chat system (DMs, Groups).
- [x] Notifications table.
- [x] SQL Triggers for automatic notification generation.

## Phase 6: Events & Communities (Current)

- [ ] Groups table (Categories, tags, privacy levels, members with RBAC).
- [ ] Events table (Online/Offline, RSVP, coordinates).
- [ ] Post integration (`group_id`).
- [ ] Chat channel auto-linking.

## Phase 7: Administration & Polish (Upcoming)

- [ ] Admin panel and Moderation system (Reports).
- [ ] Dark mode & PWA.
- [ ] Final scalability check.

# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- Phase 6 (in progress): Architecture for Groups and Events, unified feed integration.
- `ROADMAP.md` and `CHANGELOG.md` to track project evolution.

## [Phase 5] - Real-Time Chat & Notifications

### Added

- Schema for `chat_channels`, `chat_participants`, and `chat_messages` (supporting rich message types).
- Unified `notifications` table.
- PostgreSQL Triggers to automatically create notifications for friend requests and likes.
- UI Chat Layout using shadcn components (scroll-area).

## [Phase 4] - Feed & Content

### Added

- Unified `posts` table replacing fragmented content types.
- Post attachments (`post_images`, `post_videos`).
- Comments and Likes infrastructure.
- Strict RLS ensuring visibility rules (Public, Friends Only).
- `DATABASE.md` architecture document.
- Basic Feed UI (`PostCard`).

## [Phase 3] - Core Social

### Added

- Split relationship schema (`friendships`, `follows`, `blocks`).
- Granular `privacy_settings` tied to profiles.
- Profile Header UI components.

## [Phase 2] - Auth & Database Base

### Added

- Supabase SDK integration with `@supabase/ssr`.
- Authentication forms (Login/Register).
- Base `profiles` table with automatic triggers on user signup.

## [Phase 1] - Initial Setup

### Added

- React 19 + TanStack ecosystem (Router, Start, Query).
- TailwindCSS v4 + shadcn/ui.
- Multi-stage Dockerfile for production deployment on Coolify.

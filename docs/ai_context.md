# AI Context

## Project goals

Build EpicBlocks as a production-quality, offline Android-first Flutter game.
The app must stay standalone and must not depend on EpicShikaku code.

## Shared rules

Read the EpicPlay root docs before editing this app:

- `../README.md`
- `../docs/app_standards.md`
- `../docs/visual_system.md`
- `../docs/release_process.md`
- `../docs/project_template.md`
- `../templates/flutter_game`

Local docs override root defaults only when they document the reason.

## Architecture summary

- `lib/app`: app shell, theme, settings, update controller, and app-level
  services.
- `lib/core`: metadata and reusable services.
- `lib/features/settings/presentation`: settings UI.
- `lib/features/blocks`: block puzzle domain, controller, and presentation.

Keep domain logic independent from Flutter widgets.

## Project-specific warnings

- Keep Settings behind the app-bar cog.
- Keep update checks user-initiated and binary: `up to date` or `get update`.
- Keep shape placement, line clearing, scoring, and loss detection testable in
  the domain/application layers.
- Do not commit keystores, passwords, or decoded signing secrets.

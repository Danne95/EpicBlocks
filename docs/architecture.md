# Architecture

EpicBlocks uses a small layered Flutter architecture.

## Layers

### App

`lib/app` contains the app shell, top-level widget, settings state, theme
configuration, and direct APK update orchestration.

### Core

`lib/core` contains static app metadata and reusable platform services such as
vibration.

### Feature: Settings

`lib/features/settings` owns Settings presentation. Settings state and
persistence live under `lib/app` because theme, vibration, and sound affect the
whole app.

### Feature: Blocks

`lib/features/blocks` owns the playable 1010-style game.

- `domain`: board, positions, shapes, placement validation, line clears, and
  scoring.
- `application`: mutable game state, shape dealing, active-game persistence,
  high score persistence, and loss detection.
- `presentation`: Flutter board, score display, shape tray, drag/drop, and
  game-over UI.

## Dependency direction

Dependencies point inward:

`presentation -> application -> domain`

The domain layer must not depend on Flutter widgets except immutable color data
on shape definitions.

## State management

Provider is used for app and game controllers.

## Direct APK updates

Direct APK updates use `settings presentation -> app update controller -> app
update service -> GitHub Releases / Android package installer`.

Update checks are the only intentional network operation. They are
user-initiated from Settings, read public GitHub Releases, and keep the visible
player UI limited to `up to date` or `get update`.

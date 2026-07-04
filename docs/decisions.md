# Decisions

Record durable project decisions here. Keep newest decisions at the bottom.

## 2026-06-29

### Decision

Use Flutter, Dart, Material 3, Provider, and Android-first EpicPlay defaults.

### Reason

EpicBlocks is a small offline Flutter game distributed as a direct Android APK.

### Alternatives considered

No backend, accounts, ads, analytics, or background networking are included.

## 2026-06-29

### Decision

Use a documented EpicBlocks scoring rule instead of trying to clone an
undocumented 1010! bonus table.

### Reason

The app needs predictable, testable scoring. Public references confirm placement
points and line-clear combo bonuses, but no authoritative official 1010! bonus
table was found.

### Alternatives considered

Exact clone scoring was rejected until an official source is available.

## 2026-06-29

### Decision

Keep Settings as a secondary app-bar cog flow.

### Reason

Gameplay is the primary surface. Settings should be easy to reach without
becoming equal to gameplay navigation.

## 2026-07-04

### Decision

Keep the top app bar limited to Settings during normal gameplay.

### Reason

EpicBlocks does not need a manual reset action while a game is in progress.
The new-game action belongs in the game-over panel.

### Alternatives considered

An app-bar refresh button was removed because it looked like a useful action but
only discarded the current board.

## 2026-07-04

### Decision

Assign colors by shape family, not by orientation.

### Reason

Players should learn a stable visual identity for each shape type. Rotated
versions of bars, corners, large L pieces, T pieces, S pieces, and Z pieces use
the same light-mode and dark-mode colors.

### Alternatives considered

Per-orientation colors were rejected because they made related shapes look
unrelated.

## 2026-07-04

### Decision

Support direct APK update checks from Settings using public GitHub Releases.

### Reason

EpicBlocks is distributed directly as an APK. The app can guide players to a
newer public release without adding accounts, a backend, analytics, or an app
store dependency.

### Alternatives considered

Opening GitHub in a browser was rejected because it pushes the player through a
manual download flow. Background update checks were rejected because EpicPlay
apps keep update checks user-initiated.

## 2026-07-04

### Decision

Sign public APK releases with one stable GitHub Actions release keystore.

### Reason

Android only installs an APK update over an existing app when both APKs share
the same signing certificate and the new version code is higher.

### Alternatives considered

Debug signing was rejected for public updates because it can differ between
local and CI builds and can cause Android's generic `App not installed` error.

## 2026-07-04

### Decision

Center dragged shapes around the pointer and make each occupied tray slot the
pickup target.

### Reason

The previous drag behavior required the player to hold the shape's top-left
cell over the target board cell. That made touch placement awkward and made
small previews hard to pick up.

### Alternatives considered

Keeping top-left placement with larger previews was rejected because it would
still make the visible drop point differ from the player's natural grip point.

## 2026-07-04

### Decision

Lift held shapes above the finger and match placement to the lifted shape's
board position.

### Reason

This matches the 1010-style drag feel: the player can see the target board
cells because the held shape is not hidden under the finger, and the board
preview marks the cells under the lifted shape.

### Alternatives considered

Keeping the held shape centered under the finger was rejected because it hides
too much of the intended placement area on touch screens.

## 2026-07-04

### Decision

Persist the active EpicBlocks game locally and resume it on app startup.

### Reason

Games can last across multiple play sessions. Closing the app should not force
the player to abandon an in-progress board.

### Alternatives considered

Only saving the high score was rejected because it loses long-running games.

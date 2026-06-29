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

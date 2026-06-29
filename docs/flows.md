# Flows

## App startup

1. `main.dart` initializes Flutter bindings.
2. Settings load from SharedPreferences.
3. The game controller loads the local high score and creates a new game.
4. The app starts in the selected theme.
5. The game screen is shown by default.

## Gameplay

1. The player sees a 10 by 10 board and three available shapes.
2. The player drags a shape from the tray onto the board.
3. The controller accepts the move only if every cell fits and lands on empty
   board cells.
4. Accepted moves add placement points, clear full rows and columns, and add
   combo bonuses.
5. A used shape disappears from the tray.
6. When all three tray slots are used, three new shapes are dealt.
7. The game ends when no remaining tray shape can fit anywhere on the board.

## Settings

1. The player opens Settings from the cog icon in the app bar.
2. The player can toggle dark mode, vibration, and sound.
3. Settings persist immediately.
4. Patch notes appear above the version and signature footer.

## Direct APK update

1. The player opens Settings.
2. The player taps Check for updates.
3. The app checks `Danne95/EpicBlocks` latest GitHub Release.
4. If no newer release exists, the button shows `up to date`.
5. If a newer release exists, the button shows `get update`.
6. The APK downloads only after user action.
7. Android install permission is opened if needed.
8. Android's package installer handles installation.

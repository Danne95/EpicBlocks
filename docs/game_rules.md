# Game Rules

## Objective

Score as many points as possible by placing block shapes on a 10 by 10 board
and clearing full rows and columns.

## Player actions

- Drag one of the three available shapes onto the board.
- Start a new game from the game-over panel.
- Open Settings from the app-bar cog.

## Valid moves

A placement is valid when every cell in the dragged shape:

- stays inside the 10 by 10 board, and
- lands on an empty board cell.

## Invalid moves

A placement is rejected when any shape cell would leave the board or overlap an
occupied cell.

## Shape tray

The player has three shapes at a time. Placed shapes disappear from the tray.
When all three slots are empty, the game deals three new shapes.
Shape colors are stable by shape family, so rotated versions of the same shape
use the same light-mode and dark-mode colors.

## Clears

After every valid placement, all full rows and columns clear simultaneously.

## Scoring

- Placing a shape scores `1` point per placed cell.
- Let `r` be the total number of rows plus columns cleared by that placement.
- Clear bonus is `5 * r * (r + 1)`.
- Examples: one cleared line gives 10 bonus points, two cleared lines give 30,
  and three cleared lines give 60.

## Game over

The game is lost when none of the remaining available shapes can be placed
anywhere on the board.

## Persistence

High score is saved locally on the device.

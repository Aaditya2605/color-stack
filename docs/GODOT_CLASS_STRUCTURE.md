# Godot Class Structure

## GameManager.gd
- Owns the state machine and difficulty scaling.
- Spawns active blocks and coordinates tower/UI updates.
- Tracks score, streak, time, and best score.

## BlockController.gd
- Handles color cycling for the active block.
- Locks color on drop and animates the fall.
- Emits signals on reach tower and on mismatch effect complete.

## TowerController.gd
- Maintains tower stack data and visuals.
- Resolves match vs mismatch using Required Color.
- Applies growth/shrink animations and clamps height.

## UIController.gd
- Displays Required Color (swatch + icon + text).
- Displays score, streak, and game over screen.
- Handles colorblind mode toggles.

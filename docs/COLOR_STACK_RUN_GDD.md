# Color Stack Run - Game Design Document (Concise)

## One-liner
A one-finger timing game where a color-cycling block must match the tower's Required Color to grow; misses shrink the tower until game over.

## Target Audience
Kids and teens; learnable in under 10 seconds; endlessly replayable; portrait only.

## Core Loop
1) Tower shows Required Color.
2) A stationary block at top cycles colors at a fixed rhythm.
3) Player taps to drop it immediately (or auto-drop fires).
4) Match: block snaps on, score + streak up, Required Color updates.
5) Mismatch: block shatters/bounces, tower shrinks, streak resets.
6) Repeat faster and with more colors over time.

## Controls
- Single tap: drop the active block immediately.
- No drag, no positioning.

## Core Rules (Locked)
- Only one active block exists at any time.
- Active block is stationary and cycles colors at a fixed rhythm.
- Required Color is visible and fixed during the active block.
- Match attaches and grows the tower; mismatch never attaches and shrinks the tower.
- Game over at tower height 0.

## Visual + Audio
- Bright, flat, kid-friendly blocks with strong contrast.
- Required Color displayed as a large swatch + label + icon.
- Success: snap + pop sound; streak milestones: sparkle + chime.
- Mismatch: crack/bounce sound + quick shrink animation.
- Colorblind mode: add pattern/icon overlay per color.

## Progression and Difficulty
- Faster color cycling over time.
- More colors introduced: 3 -> 4 -> 5.
- Auto-drop window tightens over time.
- No randomness in Required Color during a single block attempt.

## Scoring
- Base: +10 per successful placement.
- Streak multipliers:
  - 1-5: x1
  - 6-10: x2
  - 11-20: x3
  - 21+: x4
- Optional fever (after N hits): brief x2 points or wildcard match; keep duration short and rare.

## Failure
- Mismatch shrinks tower by N blocks (start at 1; can increase with time).
- Clamp tower height at 0.
- Game over at 0 with score and best score.

## Accessibility
- Colorblind mode: pattern/icon overlay per color.
- Required Color always shown as text + icon.

---

# State Machine (Text Diagram)
Idle
  -> SpawnActiveBlock
  -> CycleColor
  -> AwaitInputOrAutoDrop
  -> Drop
  -> ResolveMatchOrMismatch
  -> UpdateScoreAndTower
  -> CheckGameOver
  -> SpawnActiveBlock (loop)
  -> GameOver (if tower height == 0)

---

# Core Mechanics Pseudocode

GameStart:
  towerHeight = 1
  score = 0
  streak = 0
  requiredColor = PickRequiredColor()
  SpawnActiveBlock()

SpawnActiveBlock:
  activeBlock = CreateBlockAtTop()
  activeBlock.StartColorCycle(cycleSpeed, colorSet)
  StartAutoDropTimer(autoDropTime)

OnPlayerTap or OnAutoDrop:
  LockActiveBlockColor()
  DropActiveBlock()

OnBlockReachTower:
  if activeBlock.color == requiredColor:
    SnapBlockToTower()
    towerHeight += 1
    streak += 1
    score += BaseScore * MultiplierFor(streak)
    requiredColor = PickRequiredColor() // after success only
  else:
    PlayMismatchEffect()
    towerHeight = max(0, towerHeight - shrinkAmount)
    streak = 0
  DestroyActiveBlock()
  if towerHeight == 0:
    TriggerGameOver()
  else:
    UpdateDifficultyByTimeOrScore()
    SpawnActiveBlock()

UpdateDifficultyByTimeOrScore:
  Increase colorCycleSpeed
  If time thresholds crossed: increase color count
  Shorten autoDropTime

---

# Difficulty Tuning Table (Example)
# Time in seconds from start.

| Time | Cycle Speed (sec per color) | Colors | Auto-drop (sec) | Shrink (N) |
|------|------------------------------|--------|-----------------|------------|
| 0-20 | 0.60                         | 3      | 3.0             | 1          |
| 21-45| 0.50                         | 3      | 2.6             | 1          |
| 46-75| 0.42                         | 4      | 2.2             | 1          |
| 76-110| 0.36                        | 4      | 1.9             | 1          |
| 111-160| 0.32                       | 5      | 1.6             | 2          |
| 161+ | 0.28                         | 5      | 1.4             | 2          |

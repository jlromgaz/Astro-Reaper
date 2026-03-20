# Skill: Rebalance Run

## Overview
Procedure for reviewing and adjusting the balance of a full run.

## Steps

### 1. Collect Run Data
Play a full run (or simulate) and record:
- Time to first level-up
- Time to first power spike (3rd upgrade)
- TTK (Time to Kill) for basic enemies at minute 1, 3, 5, 8
- Player deaths: when and why
- Number of upgrades selected
- Final build composition
- Total run duration

### 2. Review Key Metrics

#### XP Pacing
- **Target:** First level-up at ~30 seconds
- **Check:** `xp_per_enemy * enemies_per_minute ≥ xp_required / 0.5`
- **Fix:** Adjust `xp_per_enemy` or `xp_to_level` values

#### TTK (Time to Kill)
- **Minute 1:** Basic enemy dies in < 1 second
- **Minute 5:** Basic enemy dies in < 2 seconds
- **Minute 8:** Basic enemy dies in < 3 seconds (player should feel powerful despite scaling)
- **Fix:** Adjust enemy HP scaling or player damage scaling

#### Difficulty Curve
- **Check:** Is there a smooth ramp, or sudden difficulty spikes?
- **Check:** Does the player feel both challenged and powerful?
- **Fix:** Adjust `data/balance/difficulty_curve.tres`

#### Upgrade Impact
- **Check:** Does each upgrade level feel meaningful?
- **Check:** Are there "trap" upgrades that never feel good?
- **Fix:** Adjust per_level_values in upgrade resources

### 3. Adjust Data Files
All adjustments go to `data/balance/`:
- `difficulty_curve.tres` — enemy count, HP, speed scaling
- `xp_table.tres` — XP requirements per level
- `stat_scaling.tres` — player stat growth curves
- Individual weapon/enemy `.tres` files as needed

### 4. Validate Changes
- [ ] First power spike still feels impactful at ~90 seconds
- [ ] Build identity emerges by minute 3
- [ ] Player doesn't die before first upgrade (unless very poor play)
- [ ] Peak chaos at minute 7-8 is spectacular but survivable
- [ ] No single upgrade path dominates all others
- [ ] Boss is beatable with an average build

### 5. Document
Record balance changes and rationale in `.agents/reports/balance-log.md`

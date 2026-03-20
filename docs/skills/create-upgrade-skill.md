# Skill: Create Upgrade

## Overview
Standard procedure for adding a new upgrade to the level-up system.

## Steps

### 1. Define Upgrade Data Resource
Create a new `.tres` file in `data/upgrades/`:
```gdscript
# upgrade_[name].tres
upgrade_name: String
description: String
icon_path: String
rarity: String  # "common", "uncommon", "rare", "epic", "legendary"
max_level: int
category: String  # "weapon", "stat", "passive", "synergy"
effect_type: String  # "flat", "percent", "unlock"
per_level_values: Array[float]
prerequisites: Array[String]  # upgrade IDs required
conflicts: Array[String]  # mutually exclusive upgrades
weight: float  # selection probability
tags: Array[String]  # for synergy matching: "plasma", "ballistic", "drone", etc.
```

### 2. Implement Upgrade Effect
In `scripts/systems/upgrade_system.gd`:
- Add case for new upgrade in `apply_upgrade()` function
- Handle per-level scaling
- Update player stats or unlock weapon/system

### 3. Create UI Card
- Icon (16×16 or 32×32 pixel art)
- Name displayed clearly
- Short description (max 2 lines)
- Level indicator (I, II, III...)
- Rarity color border

### 4. Configure Synergies (if applicable)
- Define tag combinations that trigger evolution
- Document synergy in `data/upgrades/synergies.tres`
- Example: `["plasma", "drone"]` → "Plasma Drone Evolution"

### 5. Test
- [ ] Upgrade appears in level-up selection
- [ ] Effect applies correctly at all levels
- [ ] Stacks correctly with existing upgrades
- [ ] UI card displays correctly
- [ ] Rarity weight works (rare upgrades appear less frequently)
- [ ] Prerequisites work (locked until conditions met)
- [ ] No stat overflow or broken interactions

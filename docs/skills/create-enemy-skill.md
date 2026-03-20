# Skill: Create Enemy

## Overview
Standard procedure for adding a new enemy to the game.

## Steps

### 1. Define Enemy Data Resource
Create a new `.tres` file in `data/enemies/`:
```gdscript
# enemy_[name].tres
enemy_name: String
hp: int
damage: int
move_speed: float
xp_value: int
sprite_path: String
behavior: String  # "chase", "kamikaze", "ranged", "orbit"
spawn_weight: float
min_spawn_minute: float
```

### 2. Create Enemy Scene
Create `scenes/enemies/enemy_[name].tscn`:
- Root: `CharacterBody2D` or `Area2D`
- Children: `Sprite2D`, `CollisionShape2D`, `HitboxComponent`, `HealthComponent`
- Set collision layer: 2 (Enemies)
- Set collision mask: 1 (Player), 3 (Player bullets)

### 3. Create/Assign Controller Script
Create `scripts/enemies/enemy_[name].gd` or reuse `enemy_base.gd`:
- Load enemy data from resource
- Implement behavior pattern
- Connect death signal to XP drop system
- Connect damage signals to health component

### 4. Register in Spawn Table
Add entry to `data/enemies/spawn_table.tres`:
- spawn_weight
- min_spawn_minute
- max_concurrent (optional)

### 5. Test
- [ ] Enemy spawns at the correct time
- [ ] Movement pattern works correctly
- [ ] Takes damage and dies
- [ ] Drops correct XP value
- [ ] No performance issues with 20+ active
- [ ] Visually readable at game resolution

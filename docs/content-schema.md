# Content Schema — Astro Reaper

## Overview
This document defines the data schemas for all configurable game content. All balance and content data is defined as **Godot Resources** (`.tres`) and lives in the `data/` directory.

---

## WeaponData

**Location:** `data/weapons/weapon_[name].tres`

```gdscript
class_name WeaponData extends Resource

@export var weapon_name: String
@export var description: String
@export var icon: Texture2D

# Combat stats
@export var damage: float = 10.0
@export var fire_rate: float = 2.0        # shots per second
@export var projectile_speed: float = 300.0
@export var projectile_count: int = 1
@export var spread_angle: float = 0.0     # degrees
@export var pierce: int = 0               # enemies pierced (0 = destroys on hit)
@export var range: float = 0.0            # 0 = infinite

# Behavior
@export var targeting: String = "forward" # "forward", "nearest", "random", "orbital"
@export var projectile_scene: PackedScene

# Scaling
@export var damage_per_level: float = 3.0
@export var fire_rate_per_level: float = 0.2
@export var max_level: int = 5
```

---

## EnemyData

**Location:** `data/enemies/enemy_[name].tres`

```gdscript
class_name EnemyData extends Resource

@export var enemy_name: String
@export var sprite: Texture2D

# Stats
@export var hp: float = 20.0
@export var damage: float = 10.0
@export var move_speed: float = 60.0
@export var xp_value: int = 1

# Behavior
@export var behavior: String = "chase"    # "chase", "kamikaze", "ranged", "orbit", "elite"
@export var attack_range: float = 0.0     # for ranged enemies
@export var attack_cooldown: float = 1.0  # for ranged enemies

# Spawn config
@export var spawn_weight: float = 1.0
@export var min_spawn_minute: float = 0.0
@export var max_concurrent: int = 20

# Scaling
@export var hp_scale_per_minute: float = 1.1
@export var speed_scale_per_minute: float = 1.02
```

---

## UpgradeData

**Location:** `data/upgrades/upgrade_[name].tres`

```gdscript
class_name UpgradeData extends Resource

@export var upgrade_name: String
@export var description: String
@export var icon: Texture2D

# Classification
@export var rarity: String = "common"     # "common", "uncommon", "rare", "epic", "legendary"
@export var category: String = "stat"     # "weapon", "stat", "passive", "synergy"
@export var max_level: int = 5

# Effect
@export var effect_type: String = "flat"  # "flat", "percent", "unlock"
@export var stat_target: String = ""      # "damage", "fire_rate", "max_hp", etc.
@export var per_level_values: Array[float] = []

# Selection
@export var weight: float = 1.0           # probability weight
@export var tags: Array[String] = []      # for synergy matching
@export var prerequisites: Array[String] = []
@export var conflicts: Array[String] = []
```

---

## ShipData

**Location:** `data/ships/ship_[name].tres`

```gdscript
class_name ShipData extends Resource

@export var ship_name: String
@export var description: String
@export var sprite: Texture2D

# Base stats
@export var max_hp: float = 100.0
@export var move_speed: float = 120.0
@export var pickup_radius: float = 40.0
@export var starting_weapon: String = "blaster"

# Modifiers
@export var damage_mult: float = 1.0
@export var fire_rate_mult: float = 1.0
@export var armor: float = 0.0
@export var crit_chance: float = 0.05
@export var luck: float = 1.0

# Unlock
@export var unlocked_by_default: bool = true
@export var unlock_condition: String = ""
```

---

## DifficultyWave

**Location:** `data/balance/difficulty_curve.tres`

```gdscript
class_name DifficultyWave extends Resource

@export var minute_start: float
@export var minute_end: float
@export var enemies_per_spawn: int
@export var spawn_interval: float          # seconds between spawns
@export var hp_multiplier: float = 1.0
@export var speed_multiplier: float = 1.0
@export var elite_chance: float = 0.0
@export var allowed_enemies: Array[String] = []
```

---

## XPTable

**Location:** `data/balance/xp_table.tres`

```gdscript
class_name XPTable extends Resource

@export var base_xp_to_level: int = 5
@export var xp_scaling: float = 1.15       # multiplier per level
@export var max_level: int = 50
```

---

## Summary

| Schema | Location | Purpose |
|--------|----------|---------|
| WeaponData | `data/weapons/` | Weapon stats, targeting, and scaling |
| EnemyData | `data/enemies/` | Enemy stats, behavior, and spawn config |
| UpgradeData | `data/upgrades/` | Upgrade effects, rarity, and selection |
| ShipData | `data/ships/` | Ship base stats and modifiers |
| DifficultyWave | `data/balance/` | Per-minute difficulty scaling |
| XPTable | `data/balance/` | XP requirements per level |

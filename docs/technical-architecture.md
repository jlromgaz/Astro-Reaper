# Technical Architecture — Astro Reaper

## Stack
- **Engine:** Godot 4.6
- **Language:** GDScript
- **Platform:** Android (landscape)
- **Resolution:** 480×270 (viewport stretch mode, expand aspect)
- **Rendering:** Mobile renderer (OpenGL ES 3.0)

---

## Folder Structure

```
project/
├── agents/              # AI agent role definitions
├── assets/
│   ├── art/
│   │   ├── ships/       # Player ship sprites
│   │   ├── enemies/     # Enemy sprites
│   │   ├── bullets/     # Projectile sprites
│   │   ├── ui/          # UI elements
│   │   ├── backgrounds/ # Parallax layers
│   │   └── fx/          # VFX sprites/particles
│   ├── audio/
│   │   ├── sfx/         # Sound effects
│   │   └── music/       # Background music
│   └── fonts/           # Game fonts
├── data/
│   ├── weapons/         # Weapon resources (.tres)
│   ├── enemies/         # Enemy resources (.tres)
│   ├── upgrades/        # Upgrade resources (.tres)
│   ├── ships/           # Ship resources (.tres)
│   └── balance/         # Difficulty curves, XP tables
├── scenes/
│   ├── main/            # Main game scene, game manager
│   ├── player/          # Player ship scene
│   ├── enemies/         # Enemy scenes
│   ├── bullets/         # Projectile scenes
│   ├── pickups/         # XP and pickup scenes
│   ├── ui/              # HUD, menus, popups
│   ├── systems/         # Spawner, upgrade system, etc.
│   └── bosses/          # Boss encounter scenes
├── scripts/
│   ├── core/            # Singletons, game state, events
│   ├── components/      # Reusable components (health, hitbox, etc.)
│   ├── systems/         # Game systems (spawner, upgrades, etc.)
│   ├── factories/       # Object creation / pooling
│   └── utils/           # Helper functions, math, etc.
├── tests/               # Test scenes and scripts
├── docs/                # Design documents
│   └── skills/          # Skill guides
├── .agents/             # Antigravity config
│   ├── reports/         # Development reports
│   ├── skills/          # Antigravity skill files
│   └── workflows/       # Automated workflows
├── AGENTS.md
└── README.md
```

---

## Architectural Principles

### 1. Composition over Inheritance
Use component nodes attached to entities instead of deep class hierarchies:
```
Enemy (CharacterBody2D)
  ├── Sprite2D
  ├── CollisionShape2D
  ├── HealthComponent       # ← reusable
  ├── HitboxComponent       # ← reusable
  ├── DropComponent         # ← reusable
  └── MovementComponent     # ← reusable
```

### 2. Data Outside Code
All balance values live in Resource files:
```gdscript
# data/weapons/weapon_blaster.tres
class_name WeaponData extends Resource

@export var weapon_name: String
@export var damage: float
@export var fire_rate: float
@export var projectile_speed: float
```

### 3. Signals for Decoupling
Systems communicate through Godot signals, never direct references:
```gdscript
# Events bus (autoload singleton)
signal enemy_killed(enemy_data, position)
signal xp_collected(amount)
signal player_leveled_up(new_level)
signal upgrade_selected(upgrade_data)
```

### 4. Scenes Small and Reusable
- One scene = one responsibility
- Scenes composable via instancing
- No "god scenes" with everything

---

## Collision Layer Map

| Layer | Name           | Purpose                      |
|-------|----------------|------------------------------|
| 1     | Player         | Player ship body             |
| 2     | Enemies        | Enemy bodies                 |
| 3     | Player Bullets | Player projectiles           |
| 4     | Enemy Bullets  | Enemy projectiles            |
| 5     | Pickups        | XP gems, power-ups           |
| 6     | Obstacles      | Asteroids, debris (future)   |

---

## Core Systems

### Game Manager (Autoload)
- Manages game state (menu, playing, paused, game_over)
- Tracks run timer
- Coordinates pause on level-up

### Event Bus (Autoload)
- Central signal hub for cross-system communication
- Prevents spaghetti signal connections

### Spawn System
- Wave-based enemy spawning
- Difficulty curve from `data/balance/`
- Spawn outside camera viewport
- Entity count limits

### Upgrade System
- Pool of available upgrades from `data/upgrades/`
- Selection logic (rarity weights, prerequisites)
- Applies stat changes to player
- Tracks current build state

### Object Pool
- Pre-instantiated projectiles, pickups, enemies
- Recycle instead of create/destroy
- Configurable pool sizes

---

## Performance Guidelines
- Max entities: ~200 active nodes
- Projectile pool: 100+
- Enemy pool: 50+
- Pickup pool: 100+
- Target FPS: 60 (min 30)
- Use `_physics_process()` for gameplay, `_process()` only for visual

# Skill: Create Weapon

## Overview
Standard procedure for adding a new weapon or offensive system to the game.

## Steps

### 1. Define Weapon Data Resource
Create a new `.tres` file in `data/weapons/`:
```gdscript
# weapon_[name].tres
weapon_name: String
damage: float
fire_rate: float  # shots per second
projectile_speed: float
projectile_count: int
spread_angle: float
pierce: int  # number of enemies to pierce
range: float
cooldown: float
targeting: String  # "forward", "nearest", "random", "orbital"
sprite_path: String
projectile_scene: String
```

### 2. Create Projectile Scene
Create `scenes/bullets/bullet_[name].tscn`:
- Root: `Area2D`
- Children: `Sprite2D`, `CollisionShape2D`
- Collision layer: 3 (Player bullets)
- Collision mask: 2 (Enemies)
- Attach movement + lifetime logic

### 3. Create Weapon Controller
Create `scripts/systems/weapon_[name].gd`:
- Load weapon data from resource
- Implement fire pattern (cooldown-based)
- Handle targeting logic
- Spawn projectiles from pool
- Connect to player stats for scaling

### 4. Register in Upgrade Pool
Add weapon as unlockable in `data/upgrades/`:
- First level: unlock weapon
- Levels 2-5: stat upgrades (damage, fire_rate, pierce, etc.)

### 5. Visual Feedback
- Muzzle flash or fire animation
- Impact effect on enemy hit
- Sound effect on fire

### 6. Test
- [ ] Weapon fires at correct rate
- [ ] Damage applies correctly
- [ ] Targeting works as designed
- [ ] Visual feedback is clear
- [ ] Projectiles clean up after lifetime/hit
- [ ] Scales correctly with stat upgrades
- [ ] No performance issues with rapid fire

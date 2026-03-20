---
description: How to create a new weapon for Astro Reaper
---

# Create Weapon Workflow

## Steps

1. Define the weapon concept: name, targeting type, projectile behavior
2. Create weapon data resource in `data/weapons/weapon_[name].tres` following `WeaponData` schema from `docs/content-schema.md`
3. Create projectile scene `scenes/bullets/bullet_[name].tscn` with: `Area2D` root → `Sprite2D` + `CollisionShape2D`
4. Create weapon controller script in `scripts/systems/weapon_[name].gd`
5. Generate or create placeholder sprites for projectile and muzzle flash
6. Register weapon as unlockable upgrade in `data/upgrades/`
7. Test fire rate, targeting, damage, and visual feedback
8. Verify performance with rapid fire (no pooling leaks)

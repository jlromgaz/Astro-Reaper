---
description: How to create a new enemy for Astro Reaper
---

# Create Enemy Workflow

## Steps

1. Define the enemy concept: name, behavior pattern, visual theme
2. Create enemy data resource in `data/enemies/enemy_[name].tres` following `EnemyData` schema from `docs/content-schema.md`
3. Generate or create placeholder sprite — follow `docs/skills/create-ai-asset-skill.md`
4. Create enemy scene `scenes/enemies/enemy_[name].tscn` with: `CharacterBody2D` root → `Sprite2D` + `CollisionShape2D` + `HealthComponent` + `HitboxComponent`
5. Create or assign controller script `scripts/enemies/enemy_[name].gd`
6. Register in spawn table `data/enemies/spawn_table.tres`
7. Test using QA checklist from `agents/qa-playtest.md`
8. Document any balance concerns for `agents/balance-designer.md` review

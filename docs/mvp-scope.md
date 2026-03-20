# MVP Scope — Astro Reaper

## Objective
Define the exact content of the first playable version. Everything listed here **gets built**. Everything not listed here **does not get built** until this list is complete.

---

## Starting Ship
- 1 base ship
- Automatic frontal fire
- Movement via virtual joystick
- No dash in MVP (future)

## Weapons / Offensive Systems

| Weapon | Type | Description |
|--------|------|-------------|
| Frontal Blaster | Projectile | Straight shot with medium fire rate |
| Continuous Laser | Beam | Straight beam that deals continuous damage |
| Homing Missiles | Homing | Seek nearest enemy |
| Orbital Drone | Orbital | Orbits around the ship, damages on contact |
| Side Turret | Projectile | Fires to the sides |
| Rear Mine | Deploy | Drops mines that explode on contact |

## Player Stats

| Stat | Description | Base |
|------|-------------|------|
| Damage | Damage multiplier | 1.0 |
| Fire rate | Shots per second | 2.0 |
| Projectile speed | Projectile velocity | 300 |
| Range | Weapon range | - |
| Crit chance | Critical hit probability | 5% |
| Armor | Incoming damage reduction | 0 |
| Max HP | Hit points | 100 |
| Move speed | Movement speed | 120 px/s |
| Pickup radius | XP collection radius | 40 px |
| Luck | Affects upgrade quality | 1.0 |

## Enemies

| Enemy | Behavior | HP | Speed | XP |
|-------|----------|-----|-------|-----|
| Basic Drone | Slowly chases player | Low | Slow | 1 |
| Fast Kamikaze | Charges straight at player | Very low | Fast | 1 |
| Slow Tank | Chases, absorbs lots of damage | High | Very slow | 3 |
| Ranged Shooter | Fires projectiles | Medium | Medium | 2 |
| Elite with Aura | Buffs nearby enemies | High | Medium | 5 |
| Simple Boss | Attack patterns, high HP | Very high | Slow | 25 |

## Scenario
- 1 space arena
- Parallax background (2-3 layers)
- No obstacles in MVP (future)

## Meta-progression (minimal)
- Currency earned on run completion/death
- 3-5 very simple persistent upgrades (max HP, damage, pickup radius)

## Required UI
- Player HP bar
- XP bar with level indicator
- Run clock / timer
- Current level counter
- Level-up popup with 3 options
- Game Over screen with run summary
- Quick restart button

## Explicitly out of scope (DO NOT build)
- ❌ Online multiplayer
- ❌ Elaborate main menu
- ❌ Complex save system
- ❌ More than 1 arena
- ❌ Crafting
- ❌ Narrative / dialogue
- ❌ Monetization
- ❌ Leaderboards
- ❌ Achievements
- ❌ Cosmetic customization
- ❌ Elaborate tutorials

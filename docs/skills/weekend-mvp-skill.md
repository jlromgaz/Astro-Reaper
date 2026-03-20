# Skill: Weekend MVP

## Overview
Skill focused on the immediate goal: achieve a playable build in the shortest time possible.

## Mindset
- **Playability > Polish** — If it works and feels good, it's enough
- **Placeholder assets > No assets** — A colored rectangle is better than nothing
- **Temporary hardcode > Perfect system** — Refactor later
- **One complete feature > Three half-finished features**
- **Documented tech debt > Hidden tech debt**

## Priority Stack (strict order)
1. ✅ Ship moves with joystick
2. ✅ Ship auto-fires
3. ✅ Enemies spawn and chase
4. ✅ Collisions and damage work
5. ✅ Enemies die and drop XP
6. ✅ XP is collected automatically
7. ✅ Level-up with choice of 3 upgrades
8. ✅ At least 3 functional upgrades
9. ✅ Minimal HUD (HP, XP, level, timer)
10. ✅ Game over on death
11. ✅ Quick restart

## What NOT to do in a Weekend MVP
- ❌ Meta-progression system
- ❌ Elaborate main menu
- ❌ Save/load
- ❌ More than 3 enemy types
- ❌ More than 2 weapons
- ❌ Complex particle effects
- ❌ Elaborate music and SFX
- ❌ Premature optimization
- ❌ Refactoring systems that work

## Placeholder Asset Strategy
```
Player ship → colored rectangle/triangle (cyan)
Enemy basic → colored circle (red)
Enemy fast → smaller colored circle (orange)  
Bullets → small colored dots (yellow)
XP pickup → small green diamond
Background → dark blue/black gradient
HP bar → simple colored rectangle
XP bar → simple colored rectangle
```

## Time Boxing
- **Hour 1-2:** Movement + camera + joystick
- **Hour 3-4:** Shooting + projectiles + collision
- **Hour 5-6:** Enemy spawning + chase AI + death
- **Hour 7-8:** XP system + level-up + upgrade selection
- **Hour 9-10:** HUD + game over + restart
- **Hour 11-12:** Polish pass + first playtest + bug fixes

## Technical Debt to Document
After the weekend, create `docs/technical-debt.md` listing:
- Hardcoded values that should move to data files
- Missing pooling for performance
- Placeholder assets that need replacement
- Systems that need proper architecture
- Known bugs that were deprioritized

## Success Criteria
A weekend MVP is successful if:
- [ ] You can play a full run from start to death
- [ ] Level-up choices change how the game plays
- [ ] It is fun enough to play 3 times in a row
- [ ] No crashes during normal gameplay

---
description: How to run the full QA regression test checklist
---

# QA Regression Test Workflow

## Steps

1. Launch the game from Godot editor (F5)
2. Verify player movement with virtual joystick — responsive in all 4 directions
3. Verify auto-fire is working — projectiles spawn and travel forward
4. Wait for enemies to spawn — verify they appear and chase player
5. Let a projectile hit an enemy — verify damage, flash, and death
6. Collect XP drop — verify pickup radius and XP bar update
7. Reach level-up — verify popup appears and game pauses
8. Select an upgrade — verify effect applies correctly
9. Continue playing until death — verify game over screen appears
10. Restart — verify new run starts cleanly with reset state
11. Check Godot console for errors — no warnings or errors should appear
12. Note any performance issues (FPS drops, stuttering)
13. Write results summary in `.agents/reports/`

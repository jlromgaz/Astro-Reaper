# AGENTS.md — Astro Reaper

## Project

Astro Reaper is a 2D **survivors-like space auto-shooter roguelite** built in **Godot 4.6** with **GDScript** for Android.

**Fantasy pillar:** "soy una nave pequeña pero cada minuto mi build se vuelve absurda y espectacular."

---

## Product Goals

- Fast, readable, replayable runs on Android
- Strong power progression during each run
- Reach a playable version as fast as possible
- Professionalize later with monetization, retention, and content expansion
- AI-assisted production across code, content, and assets

---

## Current Scope

- **Platform:** Android only
- **Orientation:** Landscape
- **Mode:** Single-player only
- **Connectivity:** Offline only for MVP
- **Controls:** Simple virtual joystick + auto-fire
- **No multiplayer**
- **No live ops in MVP**

---

## Core Pillars

1. **Readability on small screens** — everything must be understandable in 1 second
2. **Strong power fantasy** — minute 8 must feel spectacularly more powerful than minute 1
3. **Simple but meaningful decisions** — each level-up offers clear, impactful choices
4. **Short sessions, fast retry** — seconds to start a new run
5. **Data-driven balancing** — all tuning values live in data files, not in code
6. **Mobile performance first** — pooling, entity limits, clean collision layers
7. **AI-assisted production** — IA for code, content, prompts, and asset generation

---

## Tech Stack

| Layer          | Choice                          |
|----------------|---------------------------------|
| Engine         | Godot 4.6                       |
| Language       | GDScript                        |
| Resolution     | 320×180 or 480×270 scaled       |
| Persistence    | Local JSON / serialized resources |
| Version Control| Local → GitHub                  |
| IDE            | Cursor (primary) + Antigravity  |
| Asset pipeline | AI-generated + manual refinement|

---

## Architecture Rules

- **Composition over inheritance** — use components, not deep class trees
- **Data outside code** — balance values in `data/`, not hardcoded in scripts
- **Resources for content** — define enemies, weapons, and upgrades as Resource files
- **Signals for decoupling** — UI reacts to gameplay via Godot signals, never direct calls
- **Scenes small and reusable** — one responsibility per scene
- **MVP-first** — build functional first, professionalize later
- **No circular dependencies** — explicit data flow between systems

---

## Folder Conventions

| Folder       | Purpose                                      |
|--------------|----------------------------------------------|
| `assets/`    | Art, audio, fonts                            |
| `data/`      | Tunable content (weapons, enemies, upgrades) |
| `scenes/`    | Godot scenes (.tscn)                         |
| `scripts/`   | Gameplay logic (.gd)                         |
| `docs/`      | Design and implementation notes              |
| `agents/`    | AI agent role definitions                    |
| `.agents/`   | Antigravity configuration, reports, skills   |
| `tests/`     | Test scenes and scripts                      |

---

## Coding Rules

- **No hardcoded balance** — values go in Resource files or `data/`
- **Short functions** — one clear purpose per function
- **No hidden side effects** — be explicit about state changes
- **Name by gameplay intent** — `shoot()`, `take_damage()`, `spawn_wave()`
- **Explicit data flow** — avoid globals; pass data through signals or function args
- **Comments only when they add intent** — don't comment obvious code

---

## Workflow Rules

### Before implementing a feature:
1. Restate the goal clearly
2. Identify all files to touch
3. Minimize scope — smallest path to playable
4. If MVP-critical, prefer speed over elegance

### After implementing:
1. Summarize what changed
2. List all touched files
3. Describe manual test steps
4. Mention risks, follow-up work, or known debt
5. Update relevant docs if architecture changed

---

## Testing Rules

For **any gameplay change**, validate:
- [ ] Player movement feels correct
- [ ] Enemy spawn is stable (no crashes, no runaway spawns)
- [ ] Damage/HP math is correct
- [ ] XP collection works
- [ ] Level-up flow triggers and resolves properly
- [ ] No obvious performance regression
- [ ] Joystick comfort on mobile (if touch-related change)

---

## AI Workflow Rules

- Use AI to accelerate code, content, prompts, and asset generation
- Favor **reusable prompts** and **documented generation flows**
- Keep asset naming and import conventions consistent
- Do not introduce stylistic drift between generated assets
- Always preserve pixel-art aesthetic coherence
- Prefer **placeholder assets** if they unblock gameplay faster

---

## Scope Restrictions

### Non-goals for MVP:
- Online multiplayer
- Procedural galaxy meta-map
- Narrative campaign
- Heavy shader work
- Full monetization implementation
- Live ops / seasonal systems

### Future-ready (don't block these):
- Rewarded ads
- IAP
- Battle pass / seasonal systems
- Subscriptions
- Multiple ships and content expansion

---

## Agent Roles

This project uses specialized AI agents defined in `agents/`:

| Agent                     | Responsibility                          |
|---------------------------|-----------------------------------------|
| `game-director`           | Vision coherence, scope control         |
| `gameplay-architect`      | Systems design, gameplay loops          |
| `godot-engineer`          | Scenes, nodes, signals, performance     |
| `pixel-art-integration`   | Spritesheet integration, visual pipeline|
| `ai-art-director`         | AI art generation, style consistency    |
| `balance-designer`        | Difficulty curves, stats, pacing        |
| `qa-playtest`             | Test checklists, bug validation         |
| `android-release`         | Touch input, builds, signing, export    |

---

## Skills

Reusable procedural guides in `docs/skills/` for common tasks:
- Creating enemies, weapons, upgrades
- Generating AI assets
- Rebalancing runs
- Performance optimization
- Android build/export
- Bug triage
- Weekend MVP sprints

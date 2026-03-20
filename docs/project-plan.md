# Space Survivors Android — Project Plan

## 1. Executive Summary

**Core idea:** An Android game in the style of *Vampire Survivors* / *Brotato* / *survivors-like* / *reverse bullet heaven*, but with **retro pixel-art space ships**.

The player controls a ship in space, survives waves, defeats enemies, collects experience, levels up, and chooses upgrades that change the build in real time.

**Fantasy pillar:** "I am a small ship, but every minute my build becomes absurd and spectacular."

**Direct design reference:**
- Main loop like *Vampire Survivors*
- Arcade visual readability like a space shooter
- Build progression and quick decisions
- Short, replayable, highly scalable mobile sessions

---

## 2. Genre Name

The most useful names to define it are:

- **Survivors-like**
- **Reverse bullet heaven**
- **Auto-shooter roguelite**

For internal documentation and marketing, use:

**"survivors-like space auto-shooter roguelite"**

---

## 3. Idea Evaluation

### The Good
- It is a proven formula.
- Fits well on mobile with 10–20 minute sessions.
- Allows scoping a small, fun first version.
- The space theme fits well with pixel art, simple VFX, and very clear visual progression.
- Huge margin for future content: ships, weapons, perks, elites, biomes, bosses, meta-progression.

### Risks
- Can end up as a clone without identity if you don't define a clear hook.
- Visual chaos can break readability on mobile.
- Ship control and aiming must feel great from day 1.
- Balance between builds is the project's main black hole.

### Recommended Hook
To differentiate, define one of these hooks from the start:

#### Option A — Modular ship build
Each upgrade adds physical or semi-visible modules to the ship:
- drones
- satellites
- side cannons
- orbital shield
- prow laser
- rear mines

This gives brutal visual identity.

#### Option B — Space with real navigation
Instead of a decorative background, the map has:
- asteroids
- ship debris
- radioactive zones
- gravity wells
- abandoned stations

This adds real positioning, not just kiting.

#### Option C — Faction/technology synergies
Upgrades belong to families:
- plasma
- ballistic
- energy
- drones
- alien tech

Combining branches unlocks special evolutions.

**Recommendation:** Mix **A + C**. It is the combination with the best return for a strong first version.

---

## 4. Game Format

### Closed Decision
The game will be **horizontal (landscape)**.

### Reasons
- More lateral space to read enemies, projectiles, and pickups.
- Ship combat feels more natural in horizontal.
- The "cruising through space" fantasy looks better.
- Readability of complex builds will be clearly superior.
- Fits better with the arcade/space shooter experience.

### Design Implication
All UI, HUD layout, camera framing, and combat space must be designed from the start for **landscape**.

---

## 5. Recommended Tech Stack

### Recommended Stack

#### Engine
**Godot 4.6**

#### Language
**GDScript** for initial development speed

#### AI-Generated Art and Content
- Sprites and concepts generated with AI
- UI and layout iteration with AI
- Agent support to create placeholders, prompts, variants, and visual documentation
- Later integration of refined art without breaking the pipeline

#### Audio
- Retro synthesized SFX
- Light chip/synthwave music
- Initial versions also generatable/assisted with AI

#### Persistence
- Local save in JSON / serialized resources

#### Version Control
- Initial development local
- Later export to **GitHub**

#### IDE / Development Environment
- **Cursor** as first choice
- **Claude Code** as second if you want more architecture discipline
- **Antigravity** for aggressive automations and orchestration
- You can even combine several if you define roles and guide documents well

### Why Godot Is Still the Best Decision Here
- Lower friction to start a small 2D mobile project.
- Very fast to iterate gameplay with AI assistance.
- Very good fit for pixel art and 2D projects.
- Reasonable Android export.
- Lower overhead than Unity to reach a playable build this weekend.
- Sufficient to professionalize the project later, including monetization and publication.

### Future Monetization Consideration
Although the first objective is a functional version, the project must leave the door open for a later professionalization phase:
- Occasional ads / rewarded ads
- In-app purchases
- Persistent progression
- Season pass / subscription / recurring monetization

This **does not change** the stack recommendation for the MVP: **Godot 4.6 + GDScript** remains the best bet to reach playable quickly. Monetization is designed as a later phase, not as a constraint on the first slice.

### Serious Alternative
**Unity 6 + C#** if you prioritize advanced monetization, ad SDKs, and third-party ecosystem from an early stage.

### Recommended Decision Today
- **Engine:** Godot 4.6
- **Language:** GDScript
- **Orientation:** Horizontal
- **Initial platform:** Android only
- **Base logical resolution:** 320×180 or 480×270 scaled
- **Immediate objective:** Playable build this same weekend

---

## 6. Project Guiding Principle

### Strategy
First build a **functional and fun** game. Then professionalize.

Correct order:
1. Achieve a playable version
2. Validate feel and main loop
3. Order architecture and content
4. Professionalize art, UX, monetization, retention, and publication

### Practical Consequence
You must not overdesign live ops, shop, subscription, or economy systems now. Only leave the project ready so those layers can be added later without redoing the core.

---

## 7. Core Loop

1. Enter a run.
2. The ship fires automatically or semi-automatically.
3. Move dodging enemies and collecting experience.
4. Level up.
5. Choose one of several upgrades.
6. Your build changes and scales.
7. Harder enemies and new patterns appear.
8. Elites and bosses arrive.
9. Die or survive the time limit.
10. Earn currency/meta-progress.
11. Unlock persistent upgrades or new content.

---

## 8. Design Pillars

### Pillar 1 — Readability
Everything must be understandable on mobile in 1 second:
- Recognizable enemy
- Clear pickup
- Clear hit feedback
- Clearly differentiated weapons

### Pillar 2 — Power Fantasy
Minute 8 must feel vastly more spectacular than minute 1.

### Pillar 3 — Simple but Meaningful Decisions
Each level-up must offer understandable choices:
- more damage
- more fire rate
- drones
- shield
- pierce
- chain lightning

### Pillar 4 — Short Sessions and Fast Retry
The user must take seconds to play again.

---

## 9. MVP Design

### MVP Content

#### Initial Ship
- 1 base ship
- Automatic frontal fire
- Optional dash later, not at start

#### Weapons / Systems
- Frontal blaster
- Continuous laser
- Homing missiles
- Orbital drone
- Side turret
- Rear mine

#### Stats
- damage
- fire rate
- projectile speed
- range
- crit chance
- armor
- max HP
- move speed
- pickup radius
- luck

#### Enemies
- Basic drone
- Fast kamikaze
- Slow tank
- Ranged shooter
- Elite with aura
- Simple boss

#### Scenario
- 1 space arena
- Parallax background
- Optional minimal obstacles

#### Meta-Progression
- Currency on completion
- Very small tree or simple persistent upgrades

#### UI
- HP bar
- XP bar
- Clock/timer
- Level counter
- Level-up popup
- Post-run summary

---

## 10. Systems to Build First

Recommended order:

1. Ship movement
2. Enemy spawn
3. Base firing
4. Damage and death
5. Experience drops
6. Level up with upgrade choice
7. Stats and scaling
8. Waves / difficulty director
9. HUD
10. Boss
11. Meta-progression
12. Audiovisual polish

---

## 11. Recommended Architecture

### Proposed Folder Structure

```text
project/
  addons/
  assets/
    art/
      ships/
      enemies/
      bullets/
      ui/
      backgrounds/
      fx/
    audio/
      sfx/
      music/
    fonts/
  data/
    weapons/
    enemies/
    upgrades/
    ships/
    balance/
  scenes/
    main/
    player/
    enemies/
    bullets/
    pickups/
    ui/
    systems/
    bosses/
  scripts/
    core/
    components/
    systems/
    factories/
    utils/
  tests/
  docs/
  .cursor/
    rules/
  agents/
  AGENTS.md
  CLAUDE.md
  README.md
```

### Architectural Principles
- Data outside code when possible
- Small, reusable scenes
- Composition before deep inheritance
- Clear separation between gameplay, data, and UI
- Balance configurable via data files

### Useful Patterns
- Component-based light architecture
- Event bus / Godot signals to decouple UI and gameplay
- Resources to define weapons, enemies, and upgrades
- Factory/spawner for enemies and pickups

---

## 12. Roadmap by Phase

### Phase 0 — Preproduction
**Objective:** Close vision and avoid starting blind.

**Deliverables:**
- Genre defined
- Orientation defined
- Stack definitive
- MVP feature list
- Pillars document
- Folder scheme

### Phase 1 — Technical Vertical Slice
**Objective:** Prove the game "feels good".

**Deliverables:**
- Ship moving
- Automatic firing
- 2 enemy types
- XP drop
- Level up
- Choose 3 upgrades
- Minimal HUD

### Phase 2 — Playable MVP
**Objective:** A complete functional run.

**Deliverables:**
- 6–8 enemies
- 6 weapons/systems
- 20–30 upgrades
- 1 boss
- Difficulty scaling
- Main menu
- Game over / victory
- Basic save

### Phase 3 — Retention and Content
**Objective:** Convert prototype into replayable game.

**Deliverables:**
- Meta-progression
- 2nd ship
- Weapon evolutions
- Persistent upgrades
- More bosses
- Serious balancing

### Phase 4 — Professionalization / Android Release
**Objective:** Prepare the project for real publication.

**Deliverables:**
- Stable performance
- Well-adjusted touch controls
- Correct UI sizes
- Improved audio
- Minimal onboarding
- Signed Android build
- Future monetization integration
- Publication and analytics pipeline

### 12.1 GitHub Branches by Phase

For ticket tracking (no Jira yet), use GitHub branches per phase. Logical groupings:

| Phase Group | Phases | Branch Name | Purpose |
|-------------|--------|-------------|---------|
| Foundation | Phase 0 | `main` | Preproduction (done) |
| MVP Playable | Phases 1 + 2 | `feature/mvp-playable` | Vertical slice + full playable run |
| Retention | Phase 3 | `feature/phase-3-retention` | Meta-progression, 2nd ship, evolutions |
| Release | Phase 4 | `feature/phase-4-android-release` | Polish, controls, signed build, publish prep |

---

## 13. Technical Risks and Mitigation

### Risk 1 — Too Many Nodes / Projectiles
**Mitigation:**
- Projectile pooling
- Limit maximum entity count
- Simplify collisions
- Avoid unnecessary effects

### Risk 2 — Visual Chaos on Small Screens
**Mitigation:**
- Clear sprites
- Controlled palette
- Very readable player projectiles
- Reduce pickup clutter

### Risk 3 — Boring Game After 3 Minutes
**Mitigation:**
- Ensure impactful upgrades from minute 1
- Introduce synergies early
- Vary waves and rhythm

### Risk 4 — Scope Creep
**Mitigation:**
- Freeze MVP in writing
- Don't add crafting, multiplayer, or story at the start

---

## 14. Control Design Recommendations

### Closed Decision
Controls will be a **simple joystick**.

### Recommended Implementation
- One virtual joystick to move the ship
- Automatic firing
- No second stick in MVP
- No extra buttons unless you add an active ability later

### Advantages
- Lower friction on mobile
- Easy to learn
- Perfect for survivors-like
- Reduces cognitive load and simplifies the UI

### Design Rule
All combat must be designed around:
- Satisfying movement
- Clear dodging
- Consistent autofire
- Builds that express themselves without complex inputs

---

## 15. Future Monetization Recommendations (Not for MVP)

Do not implement this in the first phase, but leave mental space for:
- Premium one-time purchase
- Rewarded ads for retry/reward
- Cosmetics
- Ship DLC or expansions

For the MVP, ignore it.

---

## 16. Recommended Next Steps

### Step 1
Close this decision today:
- **Godot 4.6 + GDScript + horizontal + single joystick**

### Step 2
Create the project locally with this minimal structure:

```text
/assets
/data
/scenes
/scripts
/docs
/agents
/.cursor/rules
AGENTS.md
CLAUDE.md
README.md
```

### Step 3
Write 4 base documents before programming too much:
- `docs/game-pillars.md`
- `docs/mvp-scope.md`
- `docs/technical-architecture.md`
- `docs/content-schema.md`

### Step 4
Build a **playable version this same weekend** with absolute focus on:
- Movement
- Autofire
- Enemies
- XP
- Level-up
- Upgrades
- Game over loop

### Step 5
Only when the base gameplay is fun, add:
- More content
- Meta-progression
- Visual polish
- Future monetization
- Export to GitHub and pipeline consolidation

---

## 17. Recommended AGENTS and Markdown Files

Given that the project will be heavily AI-assisted, the agent documentation layer is not optional: it is a central part of the production system.

### Mandatory Root File

#### `AGENTS.md`
Must contain:
- Project vision
- Stack
- Repo structure
- Architecture rules
- Checklist before closing tasks
- Testing and validation rules
- Scope restrictions
- Explicit instructions for AI-assisted work

### Claude Code Specific File

#### `CLAUDE.md`
Use as adaptation of AGENTS.md focused on:
- How to navigate the repo
- How to implement features
- What not to touch without asking
- Useful commands
- Commit style and validation

### `agents/` Folder
Create specialized agents in markdown.

#### `agents/game-director.md`
Responsible for:
- Maintaining global project coherence
- Deciding MVP priorities
- Blocking scope creep
- Converting ideas into executable tasks

#### `agents/gameplay-architect.md`
Responsible for:
- Designing systems and gameplay loops
- Validating coherence between weapons, stats, enemies, and upgrades
- Proposing low-coupling changes

#### `agents/godot-engineer.md`
Responsible for:
- Scenes
- Nodes
- Signals
- Resources
- Mobile 2D performance
- Android export

#### `agents/pixel-art-integration.md`
Responsible for:
- Integrating spritesheets
- Generating or adapting art prompts
- Naming and slicing
- Pivots
- Visual layers
- Readability guidelines

#### `agents/ai-art-director.md`
Responsible for:
- Directing visual generation with AI
- Defining coherent pixel art style
- Creating reusable prompts for ships, enemies, UI, and FX
- Validating visual consistency between assets

#### `agents/balance-designer.md`
Responsible for:
- Difficulty curves
- Stat tables
- Upgrade weights
- Expected DPS
- Pacing per minute

#### `agents/qa-playtest.md`
Responsible for:
- Creating test checklists
- Reproducing bugs
- Validating game feel
- Detecting regressions

#### `agents/android-release.md`
Responsible for:
- Touch input
- Android performance
- Build profiles
- Signing and export
- Pre-release checklist

---

## 18. Recommended IDE Skills

Create a skills/operational documentation folder so agents know how to execute recurring tasks consistently.

### Suggested Folder

```text
/docs/skills/
```

### Recommended Skills

#### `docs/skills/create-enemy-skill.md`
Defines the standard process for adding a new enemy:
- Data resource
- Scene
- Controller
- Stats
- Spawn table
- Manual test

#### `docs/skills/create-weapon-skill.md`
Process for new weapons:
- Data model
- Projectile scene
- Cooldown
- Targeting
- Scaling
- Visual feedback

#### `docs/skills/create-upgrade-skill.md`
Process for upgrades:
- Rarity definition
- Effects
- Restrictions
- Synergies
- UI card

#### `docs/skills/create-ai-asset-skill.md`
Process for generating assets with AI:
- Define visual objective
- Fix pixel art style
- Generate reusable prompt
- Save variants
- Select valid version
- Adapt naming and import pipeline

#### `docs/skills/rebalance-run-skill.md`
Process for rebalancing a run:
- Review TTK
- Review XP/min
- Review time-to-first-power-spike
- Review difficulty per minute

#### `docs/skills/fix-performance-skill.md`
Optimization checklist:
- Pooling
- Collisions
- Entity count
- Profiler
- Visual draw calls

#### `docs/skills/android-build-skill.md`
Android export checklist:
- SDK/JDK
- Export preset
- Signing
- Icons
- Permissions
- Release build

#### `docs/skills/bug-triage-skill.md`
Method for processing bugs:
- Reproduce
- Isolate
- Propose root cause
- Minimal patch
- Regression validation

#### `docs/skills/weekend-mvp-skill.md`
Skill focused on the immediate objective:
- Prioritize playability over polish
- Avoid non-essential features
- Deliver playable builds fast
- Leave documented tech debt

---

## 19. Cursor Rules

#### `.cursor/rules/project-overview.md`
Include:
- Genre
- Pillars
- MVP objective
- Readability and performance priority

#### `.cursor/rules/architecture.md`
Include:
- Scene / logic / data separation
- Signals for events
- Resources for configurable content
- No hardcoded balance in controllers

#### `.cursor/rules/coding-standards.md`
Include:
- Naming
- Script size
- Comments only when they add intent
- Short functions
- Avoid circular coupling

#### `.cursor/rules/task-execution.md`
Include:
- Don't touch several large areas without a plan
- Before changing, explain impact
- After changing, list modified files
- Always propose manual validation

---

## 20. Realistic Initial Backlog

### Sprint 1
- Create repo
- Configure Godot
- Folder structure
- AGENTS.md
- CLAUDE.md
- Cursor rules
- Player scene
- Movement
- Camera

### Sprint 2
- Base firing
- Basic enemy
- Collision and damage
- Enemy death
- XP drop

### Sprint 3
- Level-up popup
- Upgrade system
- 3 real upgrades
- Basic HUD

### Sprint 4
- Wave director
- 3 more enemies
- Basic balance
- Game over loop

### Sprint 5
- Simple boss
- Post-run rewards
- Local save
- Internal Android build

---

## 21. Final Recommendation

For this project, the most sensible option is:

- **Main IDE:** Cursor
- **Possible support:** Claude Code and/or Antigravity depending on role
- **Engine:** Godot 4.6
- **Language:** GDScript
- **Format:** Horizontal
- **Controls:** Simple joystick + auto-fire
- **Immediate objective:** Playable version this same weekend
- **Later objective:** Professionalize the product, art, retention, and monetization

Your priority should not be "making a big game", but **demonstrating fun, readability, and build scaling in a single functional run**, using AI intensively for code, content, documentation, and art.

When that works, everything else becomes much easier.

# Game Pillars — Astro Reaper

## Fantasy Pillar
> "I'm a tiny ship, but every minute my build becomes absurd and spectacular."

---

## Pillar 1 — Readability on small screens

Everything must be understandable on mobile in **1 second**:

- **Recognizable enemies** — clear silhouette, threatening color, size proportional to danger
- **Clear pickups** — glow, attractive color (green/yellow), pulse animation
- **Clear hit feedback** — white flash on damage, subtle screen shake, particle emission
- **Clearly differentiated weapons** — each weapon has unique color, firing pattern, and sound
- **Non-competing background** — cool dark tones, never distracts from gameplay

### Golden Rule
If a player can't understand what's happening on screen in less than 1 second, the visual design has failed.

---

## Pillar 2 — Progressive power fantasy

**Minute 8 must feel spectacularly more powerful than minute 1**.

- Every upgrade must have immediate visual and mechanical impact
- At peak run, the screen should be a spectacle of projectiles, drones, and explosions
- Progression should feel like "unlocking powers", not "incrementing numbers"
- Synergies between upgrades create unexpected "wow" moments

### Success Indicators
- The player smiles when they see their build in action
- The minute 8 screen looks completely different from minute 1
- The player wants to tell someone what their build did

---

## Pillar 3 — Simple but meaningful decisions

Every **level-up** must offer **understandable** decisions with real impact:

- Clear options: more damage, faster fire rate, new weapon, shield, drones...
- The player understands the difference between options in < 3 seconds
- No "trap" options that are never worth choosing
- Different combinations lead to divergent builds

### Decision Rule
If the 3 options in a level-up feel the same, the design has failed.

---

## Pillar 4 — Short sessions and fast retry

The user must take **seconds** to replay:

- Full run: **10 minutes** maximum
- From death to new run: **< 5 seconds**
- No long tutorials, no cinematics, no loading screens
- Retry motivation comes from "I want to try another build"

### Success Indicators
- The player starts 3+ runs in a 30-minute session
- Each run has a different identity due to the decisions made

---

## Pillar 5 — Data-driven balancing

All tuning values live in data files, **never hardcoded** in code:

- Weapons defined as Resources in `data/weapons/`
- Enemies defined as Resources in `data/enemies/`
- Upgrades defined as Resources in `data/upgrades/`
- Difficulty curves in `data/balance/`

### Benefit
Anyone (or any AI agent) can adjust game balance without touching a single line of code.

---

## Pillar 6 — Mobile performance first

Pooling, entity limits, and clean collision layers:

- Max ~50 simultaneous active enemies
- Max ~100 active projectiles
- Object pooling for everything that is frequently created/destroyed
- Minimal and well-defined collision layers
- Target: stable 60 FPS on mid-range Android devices

---

## Pillar 7 — AI-assisted production

AI integrated into the production pipeline:

- AI-assisted code generation with specialized agents
- Pixel art assets generated with AI + manual refinement
- Reusable documented prompts for visual coherence
- Documentation and content schemas generated with AI support
- Quickly generated placeholder assets to unblock gameplay

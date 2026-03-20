# Megabonk Design Knowledge Base (For Astro Reaper)

## 1. Overview

Megabonk is a **survivors-like / reverse bullet hell / auto-shooter roguelite**.

Core loop:

* Kill enemies
* Gain XP
* Level up
* Choose upgrades
* Build evolves dynamically

Key principle:

> Emergent builds driven by RNG + player decisions

---

## 2. Core Design Pillars

### 2.1 Emergent Build System

* No fixed builds
* Player assembles power during run
* Decisions matter every level-up

### 2.2 Power Scaling

* Weak early game
* Exponential mid-game growth
* Chaotic late game

### 2.3 System Synergy

* Weapons + Items + Tomes interact
* Strong combinations create "broken" builds

### 2.4 Replayability

* RNG-driven progression
* Multiple viable strategies

---

## 3. Characters System

### Structure

Each character defines:

* Base stats (HP, speed, damage)
* Unique passive bonus
* Playstyle archetype

Important rule:

> Characters do NOT restrict weapons

### Archetypes

* Tank (high HP, armor)
* Speed (mobility, kiting)
* Crit (precision scaling)
* Economy (gold scaling)
* RNG-based (chaotic effects)

### Example Characters

#### Sir Oofie

* Role: Tank
* Strength: Survivability
* Typical build: Defensive + AoE

#### Megachad

* Role: Melee damage
* Strength: Early power

#### CL4NK

* Role: Crit scaling
* Strength: Late-game damage

#### Robinette

* Role: Economy scaling
* Strength: Gold-based damage

#### Calcium

* Role: Speed
* Strength: Mobility

#### Dicehead

* Role: RNG-based
* Strength: High variability

---

## 4. Weapons System

### General Rules

* Acquired via level-ups
* Can be upgraded multiple times
* Have rarity tiers

### Weapon Roles

* Single Target (Sniper, Revolver)
* AoE (Aura, Explosives)
* Crowd Control (Black Hole)
* Damage Over Time (Poison)
* Utility (Defensive tools)

### Example Weapons

#### Sniper Rifle

* High burst damage
* Low fire rate

#### Revolver

* Consistent DPS

#### Lightning Staff

* Chain damage

#### Black Hole

* Pulls enemies

#### Rocket Launcher

* Explosive AoE

#### Poison Flask

* Damage over time

#### Aura

* Passive area damage

---

## 5. Tomes (Global Passive System)

### Definition

Tomes are global modifiers affecting all weapons and systems.

### Examples

* Damage
* Attack Speed
* Cooldown Reduction
* Projectile Count
* Range
* Armor
* XP Gain

### Key Design Insight

> Tomes are the most important scaling system in the game

### Characteristics

* Stackable
* Affect entire build
* Enable exponential growth

---

## 6. Items, Powerups, Interactables, and Map-Based Rewards

This section is the most important for adapting Megabonk's exploration and mid-run rewards into Astro Reaper.

### 6.1 Persistent Run Items

Items are permanent mid-run collectibles that spawn during gameplay and apply passive bonuses or proc-based effects.

Characteristics:

* They spawn during runs rather than only through level-up menus.
* They have rarity tiers.
* They often need to be unlocked before they can appear.
* They are one of the main reasons exploration matters.

Typical item functions:

* damage increase
* XP gain increase
* movement speed increase
* crit chance increase
* poison / freeze / lightning proc chances
* regen / sustain
* chest interaction modifiers
* shrine interaction modifiers
* gold gain modifiers

Design lesson for Astro Reaper:

> Your game should not rely only on level-up rewards. Map exploration should also grant meaningful, permanent build growth.

---

### 6.2 Temporary Powerups

Megabonk also includes short-duration pickups that create moment-to-moment spikes.

Important examples:

* **Heart**: restores a chunk of health
* **Magnet**: collects previously dropped XP from the map
* **Speed Boost**: temporary movement speed buff
* **Purple Lightning**: temporary offensive buff
* **Coin**: temporary extra gold gain
* **Green Shield**: temporary invincibility
* **Stopwatch**: temporarily freezes enemies / prevents damage
* **Nuke**: kills enemies in a radius

Design lesson for Astro Reaper:

* Add temporary pickups that instantly change tempo.
* They make navigation and improvisation more exciting.
* They are excellent for rescuing bad runs or amplifying strong ones.

Recommended translation:

* Repair Orb
* XP Magnet Pulse
* Thruster Overdrive
* Overclock Core
* Credit Cache
* Phase Shield
* Time Dilation Beacon
* EMP Nova

---

### 6.3 Breakables and Ambient Reward Sources

Megabonk uses destructible world objects to create low-friction reward loops.

#### Pots

* Can drop money, health, or XP.
* Encourage movement through the map.
* Good for micro-rewards and route efficiency.

#### Silver Pots

* Grant silver / meta-currency.
* Create another layer of exploration reward.

#### Tumbleweeds

* Can drop XP or gold.
* In specific cases can also drop unlock-related elements.

Design lesson for Astro Reaper:

* Add breakable space debris / cargo crates / signal buoys / wreck pods.
* These should occasionally drop:

  * XP shards
  * credits
  * healing
  * temporary powerups
  * rare unlock-related objects

---

### 6.4 Interactables and Map Structures

Megabonk uses map structures to create alternative reward routes besides leveling.

These are crucial and should absolutely inspire Astro Reaper.

#### Challenge Shrine

* Spawns dangerous enemies.
* Reward: free item chest.
* Risk/reward structure.

#### Shrine of Succ

* Pulls all previously dropped XP to the player.
* Great catch-up tool and route optimization tool.

#### Bloody Shrine / Boss Curse

* Increases boss count.
* Adds danger for more rewards.
* Excellent opt-in difficulty escalator.

#### Charge Shrine

* Player stays in an area to charge it.
* When completed, choose 1 of 3 stat rewards.
* This is one of the most important non-level-up progression systems.

#### Golden Charge Shrine

* Same structure, but with higher-tier / legendary reward quality.

#### Moai Shrine

* Offers a choice between items.
* Functions like an interactable item draft.

#### Golden Moai Shrine

* Guaranteed high-tier / legendary item choices.

#### Greed Shrine

* Gives money.
* Also increases difficulty.
* Strong example of economy vs danger tradeoff.

#### Microwave

* Duplicates an item by consuming another of same rarity.
* Limited uses.
* Extremely strong build accelerator.

#### Normal Chest

* Costs money to open.
* Chest price increases over time.
* Core economy sink.

#### Free Chest

* Usually drops from bosses, minibosses, elite enemies, challenge shrines, or special map encounters.
* Gives a free item.
* Strongest payoff for combat events.

#### Gold Chest

* Free item chest found naturally on the stage.
* More rare.

#### Shady Guy

* Merchant-like encounter.
* Lets player buy one of several offered items.

#### Special Encounter Objects

* Boomboxes
* Gold Key + Cage
* Suspicious Bush
* Bandit Statue
* These act as discovery-driven unlock or boss triggers.

Design lesson for Astro Reaper:

> The map should contain meaningful interactables that let the player improve their run without leveling up.

---

### 6.5 Reward Geography and Drop Zones

One of the most important lessons from Megabonk is that progression is spatial, not only menu-based.

Progress comes from:

* enemy kills
* level-up rewards
* chests
* breakables
* shrine rewards
* merchants
* special encounters
* map traversal

This creates informal **reward zones** across the map.

Types of reward zones you should implement in Astro Reaper:

#### A. Combat Reward Zones

Places where strong enemy packs, elites, or challenge encounters appear.

Possible rewards:

* free chest
* high XP burst
* rare pickup

#### B. Resource Scavenge Zones

Areas with breakables, salvage nodes, cargo crates, asteroid wreckage.

Possible rewards:

* credits
* healing
* XP shards
* temporary buffs

#### C. Draft / Upgrade Zones

Stations or structures where the player can choose one of several upgrades.

Megabonk equivalent:

* Charge Shrine
* Moai Shrine

#### D. Risk Zones

Optional danger nodes that increase difficulty or spawn additional threats.

Megabonk equivalent:

* Bloody Shrine
* Greed Shrine

#### E. Merchant Zones

Safe-ish locations where player can spend currency for immediate power.

Megabonk equivalent:

* Shady Guy
* chest economy

#### F. Transition / Objective Zones

Locations tied to boss progression or map transition.

Megabonk equivalent:

* Teleporter

Design rule for Astro Reaper:

> The player should constantly decide whether to keep farming, open a reward structure, buy power, trigger danger, or rush the objective.

---

### 6.6 Teleporter / Stage Transition Structure

Megabonk uses teleporters as a major run pacing tool.

Important functions:

* found somewhere on the map
* triggers stage boss / next stage progression
* creates routing pressure
* forces player to decide when to stop farming and advance

Design lesson for Astro Reaper:
Use a similar structure, but theme it as:

* jump gate
* warp gate
* hyperspace relay
* sector exit beacon

It should:

* be discoverable on the map
* represent commitment to the next combat phase
* create tension between greed and progression

---

### 6.7 Economy Design Lessons

Megabonk's chest and shrine systems prove that a survivors-like benefits from having **multiple currencies and sinks**.

Useful economy layers for Astro Reaper:

* XP for level-ups
* credits for chests / vendors / map stations
* optional meta-currency for account progression

Map economy creates more decisions than pure auto-leveling.

---

### 6.8 Recommended Astro Reaper Implementation

Do not copy everything at once. Implement this in layers.

#### Layer 1 — Essential

* breakable crates / debris
* chest system
* magnet pickup
* healing pickup
* temporary speed / damage pickup

#### Layer 2 — Mid-run strategy

* challenge beacon
* stat shrine
* item draft station
* optional difficulty beacon

#### Layer 3 — Advanced identity

* merchant drone
* duplication station
* rare legendary station
* boss unlock encounter
* sector jump gate

---

### 6.9 Direct Translation Table

| Megabonk Element     | Astro Reaper Equivalent           |
| -------------------- | --------------------------------- |
| Pots                 | Cargo crates / salvage pods       |
| Silver Pots          | Rare credit caches                |
| Tumbleweed           | Drifting debris / loot satellites |
| Challenge Shrine     | Combat Beacon                     |
| Shrine of Succ       | XP Magnet Station                 |
| Bloody Shrine        | Threat Beacon                     |
| Charge Shrine        | Overclock Shrine                  |
| Golden Charge Shrine | Legendary Overclock Shrine        |
| Moai Shrine          | Upgrade Draft Shrine              |
| Golden Moai Shrine   | Legendary Draft Shrine            |
| Greed Shrine         | Credit Beacon                     |
| Microwave            | Replicator Station                |
| Normal Chest         | Supply Crate                      |
| Free Chest           | Elite Reward Crate                |
| Gold Chest           | Rare Supply Crate                 |
| Shady Guy            | Merchant Drone                    |
| Teleporter           | Warp Gate / Jump Beacon           |

---

### 6.10 Core Principle

> A great survivors-like should reward not only killing and leveling, but also movement, exploration, routing, risk-taking, and map interaction.

This is one of the strongest systems you should borrow conceptually from Megabonk.

## 7. Build System

### Core Idea

Builds are created dynamically during runs.

### Example Combinations

#### AoE Build

* Aura + Black Hole
* Result: Map-wide clearing

#### Poison Build

* Poison + Lifesteal
* Result: Sustained damage and healing

#### Speed Build

* Movement + cooldown
* Result: Kiting gameplay

---

## 8. Progression System

### In-Run Progression

* XP collection
* Level-ups
* Upgrade selection

### Meta Progression

* Unlock weapons
* Unlock characters
* Currency-based upgrades

---

## 9. Enemy System

### Types

* Basic swarm units
* Fast attackers
* Tanks
* Ranged enemies
* Elite enemies
* Bosses

### Scaling

* Increasing density
* Increasing HP
* New enemy patterns

---

## 10. Difficulty Curve

### Early Game

* Low threat
* Slow progression

### Mid Game

* Build begins to scale
* More enemies

### Late Game

* High density
* Visual chaos
* Extreme builds

---

## 11. Design Insights for Astro Reaper

### Must Implement

#### 1. Emergent Builds

* No fixed loadouts
* Dynamic progression

#### 2. Global Modifiers (Tomes equivalent)

* Affect all systems

#### 3. Weapon Synergy

* Combine multiple attack types

#### 4. Power Fantasy

* Strong late-game escalation

#### 5. Readable Chaos

* High intensity but clear visuals

---

## 12. Translation to Astro Reaper

| Megabonk  | Astro Reaper  |
| --------- | ------------- |
| Character | Ship          |
| Weapon    | Weapon System |
| Tome      | Core Upgrade  |
| Item      | Module        |
| Enemy     | Drone / Alien |

---

## 13. Recommended MVP Scope

### Minimal Implementation

* 1 ship
* 4 weapons
* 6 upgrades
* 3 enemy types
* 1 boss

### Focus

* Movement feel
* Combat satisfaction
* Upgrade impact

---

## 14. Key Takeaways

* The game is about scaling power
* Systems must interact
* Simplicity first, complexity later
* Fun > features

---

## 15. Final Principle

> Build a fun 10-minute run first. Everything else comes after.

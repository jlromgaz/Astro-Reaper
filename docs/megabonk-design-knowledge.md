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

## 6. Items System

### Definition

Secondary modifiers that enhance specific aspects of builds.

### Examples

* Movement speed boosts
* Melee damage bonuses
* Lifesteal
* Critical modifiers

### Function

* Provide synergy with weapons
* Fine-tune builds

---

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

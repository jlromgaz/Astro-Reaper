# 🚀 Astro Reaper

**A 2D survivors-like space auto-shooter roguelite, built for Android with Godot 4.6 + GDScript — designed and shipped with an AI-assisted development workflow.**

> *"Soy una nave pequeña pero cada minuto mi build se vuelve absurda y espectacular."*

[![Engine](https://img.shields.io/badge/Engine-Godot%204.6-478CBF?logo=godotengine&logoColor=white)](https://godotengine.org/)
[![Language](https://img.shields.io/badge/Language-GDScript-355570)](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](https://developer.android.com/)
[![Backend](https://img.shields.io/badge/Backend-Firebase%20Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Testing](https://img.shields.io/badge/Testing-GUT-informational)](https://github.com/bitwes/Gut)
[![License](https://img.shields.io/badge/License-Private-lightgrey)]()

---

## 🎮 What is it?

**Astro Reaper** is a *survivors-like* auto-shooter in the spirit of *Vampire Survivors* / *Brotato*, reimagined as a retro pixel-art space shooter. Pilot a small ship, auto-fire at waves of enemies, collect XP, and stack upgrades until a run that started small turns absurd and spectacular by minute eight.

## 🛠️ Tech Stack

This project was a deliberate exercise in stepping outside my primary stack (**Java**) and building a complete, working product end-to-end in a different ecosystem — using AI as a pair-programming and architecture partner throughout.

| Layer                | Choice                                              |
|-----------------------|------------------------------------------------------|
| **Engine**            | Godot 4.6                                            |
| **Language**          | GDScript                                             |
| **Target Platform**   | Android (landscape) — with a Web export for quick sharing |
| **Backend / Online**  | Firebase Firestore (REST API leaderboard) + BigQuery export extension |
| **Data-driven design**| Godot `Resource` files for ships, weapons, enemies, upgrades |
| **Testing**           | [GUT](https://github.com/bitwes/Gut) (GDScript Unit Testing) |
| **i18n**              | EN / ES translations via Godot's localization system |
| **AI-assisted workflow** | Structured agent roles (`agents/`, `.cursor/agents/`) for architecture, gameplay, balancing, QA and art direction, plus reusable "skills" (`docs/skills/`) for recurring tasks like creating enemies, weapons and upgrades |

## ✨ Highlights

- **Composition over inheritance** — gameplay built from small, reusable components (health, hitbox, hurtbox) rather than deep class hierarchies.
- **Data outside code** — every weapon, enemy and upgrade is tuned via `Resource` files, not hardcoded values, so balance changes never require touching gameplay code.
- **Decoupled systems** — an `EventBus` and Godot signals keep UI, gameplay and audio independent of each other.
- **Global leaderboard, zero SDK weight** — talks to Firestore directly over its REST API, with all write access locked down by Firestore Security Rules (score shape/bounds validation, no edits or deletes).
- **Unit-tested core logic** — pure, side-effect-free helpers (e.g. leaderboard request/response encoding) are covered with GUT tests.
- **Mobile-first performance** — pooling, entity limits and clean collision layers, tuned for a 480×270 design resolution scaled to real devices.

## 🎯 Core Loop

1. Enter a run → 2. Auto-fire → 3. Dodge & collect XP → 4. Level up → 5. Choose upgrades → 6. Build scales → 7. Harder enemies → 8. Elites & bosses → 9. Survive or die → 10. Meta-progress

## 📁 Project Structure

```
├── agents/          # AI agent role definitions
├── assets/          # Art, audio, fonts
│   ├── art/         # Ships, enemies, bullets, UI, backgrounds, FX
│   ├── audio/       # SFX, music
│   └── fonts/
├── data/            # Tunable content (weapons, enemies, upgrades, balance) + i18n
├── docs/            # Design documents and reusable AI "skills"
├── scenes/          # Godot scenes
├── scripts/         # Gameplay logic (components, systems, UI, core services)
├── tests/           # GUT test scenes and scripts
├── .agents/         # Antigravity config, reports, skills
├── AGENTS.md        # AI agent directives & architecture rules
└── README.md
```

## 🤖 Why this project

I'm a **Java developer** exploring how AI-assisted development changes what's feasible outside my core expertise. Astro Reaper is that experiment made concrete: a full game — engine, gameplay systems, a live backend, tests and documented AI workflows — built in a language and engine I hadn't worked in before, using AI as a collaborator rather than a crutch. The `AGENTS.md` file and `docs/skills/` folder document the actual workflow used to get there.

## 🚦 Current Phase

**Phase 0 — Pre-production** ✅

## 📜 License

Private project. All rights reserved.

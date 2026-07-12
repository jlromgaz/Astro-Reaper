# Art Style Guide — Astro Reaper

**Approach:** Procedural art in code (GDScript `_draw()` / `Polygon2D` / generated textures). No external image assets. Every visual is defined by shape + palette color + glow, versioned in git.

This guide is the single source of truth for visual decisions. All colors in code MUST come from `scripts/core/palette.gd` — never hardcode `Color(...)` literals in gameplay scripts.

---

## 1. Visual Identity

**Style:** Neon vector-space. Clean geometric shapes with subtle glow on a near-black backdrop — inspired by Geometry Wars readability, with a retro-arcade feel.

Why this style (and not pixel-art sprites):
- Procedural shapes scale losslessly at any resolution (mobile → desktop → web).
- Maximum readability at high entity counts (design Pillar 1).
- Zero asset pipeline; everything reviewable in diffs.

---

## 2. Readability Hierarchy (non-negotiable)

Brightness/saturation order from most to least prominent:

| Priority | Element | Rule |
|----------|---------|------|
| 1 | Player ship | Brightest cool color on screen, unique shape |
| 2 | Enemy projectiles | Hot warning color, high contrast vs background |
| 3 | Enemies | Warm colors, one hue family per behavior class |
| 4 | Player projectiles | Player hue family, lower alpha than enemy bullets |
| 5 | Pickups | Distinct saturated accents, small |
| 6 | Background | Desaturated, dark, never competes |

**Rule:** if a screenshot at minute 8 (max chaos) makes any of rows 1–3 ambiguous, the art is wrong — fix contrast, not gameplay.

---

## 3. Master Palette

Formalized from the current de-facto colors (player cyan, enemy red, navy background) so existing scenes stay coherent.

### Background
| Name | RGB | Use |
|------|-----|-----|
| `BG_SPACE` | (0.03, 0.03, 0.08) | Base space fill |
| `BG_NEBULA` | (0.05, 0.05, 0.15) | Panels, minimap fill |
| `STAR_DIM` | (0.35, 0.40, 0.55) | Far starfield layer |
| `STAR_BRIGHT` | (0.70, 0.80, 1.00) | Near starfield layer |

### Player (cyan family)
| Name | RGB | Use |
|------|-----|-----|
| `PLAYER_CORE` | (0.20, 0.80, 1.00) | Ship body (Stellar default) |
| `PLAYER_GLOW` | (0.40, 0.90, 1.00) | Engine trail, outline glow |
| `BULLET_PLAYER` | (0.55, 0.95, 1.00) | Player projectiles |
| `SHIELD` | (0.30, 0.60, 1.00) | Shield ring |

Ship variants keep their `.tres` color as body tint; glow/bullets stay in the cyan family.

### Enemies (warm family — hue encodes behavior)
| Name | RGB | Behavior class |
|------|-----|----------------|
| `ENEMY_CHASER` | (0.90, 0.25, 0.25) | Drone, tank (contact chasers) |
| `ENEMY_FAST` | (1.00, 0.55, 0.15) | Kamikaze, interceptor (fast threats) |
| `ENEMY_RANGED` | (0.85, 0.30, 0.75) | Ranged shooter |
| `ENEMY_ELITE` | (1.00, 0.85, 0.20) | Elite / aura variants |
| `BOSS` | (1.00, 0.10, 0.60) | Boss (magenta, matches minimap) |
| `BULLET_ENEMY` | (1.00, 0.40, 0.30) | Enemy projectiles (hot, unmissable) |

### Pickups & FX
| Name | RGB | Use |
|------|-----|-----|
| `XP_GEM` | (0.30, 1.00, 0.50) | XP pickups (green) |
| `HEALTH` | (1.00, 0.30, 0.45) | Health pickups |
| `COMET` | (1.00, 0.90, 0.30) | Comet encounter (yellow) |
| `HIT_FLASH` | (1.00, 1.00, 1.00) | Damage flash (1–2 frames) |
| `EXPLOSION` | (1.00, 0.60, 0.20) | Death burst particles |

### UI
| Name | RGB | Use |
|------|-----|-----|
| `UI_TEXT` | (0.90, 0.95, 1.00) | Primary text |
| `UI_ACCENT` | (0.20, 0.80, 1.00) | Highlights, selected state |
| `UI_HP` | (0.95, 0.25, 0.35) | HP bar fill |
| `UI_XP` | (0.30, 1.00, 0.50) | XP bar fill |
| `UI_PANEL` | (0.05, 0.05, 0.15, 0.85) | Panel backgrounds |

---

## 4. Shape Language

Shape encodes role — a player must classify an entity by silhouette alone:

| Entity | Silhouette | Notes |
|--------|-----------|-------|
| Player ship | Sharp triangle / arrow | Points at aim direction, engine glow behind |
| Drone | Circle | Soft blob, slow |
| Kamikaze | Narrow triangle | Aggressive, points at player |
| Tank | Hexagon | Big, heavy, faceted |
| Ranged | Diamond | Angular, keeps distance |
| Interceptor | Chevron / dart | Fast silhouette |
| Boss | Large layered polygon | Multi-part, rotating elements |
| Player bullet | Small elongated capsule | Motion-stretched |
| Enemy bullet | Small circle with glow ring | Round = dodge this |
| XP gem | Small rotated square (gem) | Sparkle on idle |
| Comet | Triangle + trailing particles | Trail communicates trajectory |

**Rules:**
- Enemies never use the player's triangle-arrow silhouette.
- Round projectiles = enemy; elongated = player. Never mix.
- Outline: 1px lighter rim on every entity for separation from background.

## 5. Size Scale (existing collision sizes are authoritative)

| Entity | Visual size (px @ base zoom) |
|--------|------------------------------|
| Player | 24×24 |
| Drone / kamikaze | ~24 (radius 12–14) |
| Ranged / interceptor | ~24 (radius 12) |
| Tank | ~40 (radius 20) |
| Boss | 80–120 |
| Bullets | 4–8 |
| Pickups | 8–12 |

Visual size may exceed collision size slightly (glow), never the reverse — hitboxes must feel fair.

## 6. Motion & FX Rules

- **Hit feedback:** white flash (`HIT_FLASH`) 0.05s + 2px scale punch.
- **Death:** 6–10 particle burst in entity color, 0.3s, then free.
- **Engine trails:** player always has one (power fantasy); fast enemies get short trails.
- **Glow:** additive-blend halo at ~30% alpha, radius ≤ 50% of body. Never stack more than 2 glow layers per entity (mobile GPU budget).
- **Screen effects:** subtle 2–3px camera shake on player damage and boss spawn only. No shake on kills (too frequent).

## 7. Implementation Notes

- Palette lives in `scripts/core/palette.gd` as a static class (`Palette.PLAYER_CORE` etc.).
- Migrate existing `ColorRect` sprites to `Polygon2D`/custom `_draw()` nodes progressively — one entity type per change, verified in-game before the next.
- Ship `.tres` `color` remains the per-ship body tint; everything else references `Palette`.

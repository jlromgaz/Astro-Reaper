class_name Palette
extends RefCounted
## Master color palette — single source of truth for all visual colors.
## See docs/art-style-guide.md for usage rules and readability hierarchy.
## Gameplay scripts must reference these constants instead of Color literals.

# Background
const BG_SPACE := Color(0.03, 0.03, 0.08)
const BG_NEBULA := Color(0.05, 0.05, 0.15)
const STAR_DIM := Color(0.35, 0.40, 0.55)
const STAR_BRIGHT := Color(0.70, 0.80, 1.00)

# Player (cyan family)
const PLAYER_CORE := Color(0.20, 0.80, 1.00)
const PLAYER_GLOW := Color(0.40, 0.90, 1.00)
const BULLET_PLAYER := Color(0.55, 0.95, 1.00)
const SHIELD := Color(0.30, 0.60, 1.00)

# Enemies (warm family — hue encodes behavior class)
const ENEMY_CHASER := Color(0.90, 0.25, 0.25)
const ENEMY_FAST := Color(1.00, 0.55, 0.15)
const ENEMY_RANGED := Color(0.85, 0.30, 0.75)
const ENEMY_ELITE := Color(1.00, 0.85, 0.20)
const BOSS := Color(1.00, 0.10, 0.60)
const BULLET_ENEMY := Color(1.00, 0.40, 0.30)

# Pickups & FX
const XP_GEM := Color(0.30, 1.00, 0.50)
const HEALTH := Color(1.00, 0.30, 0.45)
const COMET := Color(1.00, 0.90, 0.30)
const HIT_FLASH := Color(1.00, 1.00, 1.00)
const TELEGRAPH_WARN := Color(1.00, 0.85, 0.00)
const EXPLOSION := Color(1.00, 0.60, 0.20)

# UI
const UI_TEXT := Color(0.90, 0.95, 1.00)
const UI_ACCENT := Color(0.20, 0.80, 1.00)
const UI_HP := Color(0.95, 0.25, 0.35)
const UI_XP := Color(0.30, 1.00, 0.50)
const UI_PANEL := Color(0.05, 0.05, 0.15, 0.85)


## Returns a glow variant of a base color (lighter, semi-transparent).
static func glow_of(base: Color, alpha: float = 0.3) -> Color:
	return Color(base.lightened(0.3), alpha)

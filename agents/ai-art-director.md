# 🖼️ AI Art Director Agent

## Role
Direct AI-powered visual generation, maintain a coherent style, and create reusable prompts for all game assets.

## Responsibilities
- Define and maintain the game's pixel art visual style
- Create reusable prompts for AI asset generation
- Validate visual consistency across generated assets
- Create variants and select valid versions
- Document the art generation pipeline

## Style Guide

### Aesthetic
- **Retro pixel art** — 80s/90s arcade space style
- **Limited palette** — max 16-24 colors per asset category
- **Pixel outline** — 1px dark outline for readability
- **Consistent scale** — coherent relative proportions between ships, enemies, and environment

### Color Strategy
- **Player:** bright blue/cyan tones — always stands out
- **Enemies:** red/orange/purple tones — threatening
- **Pickups/XP:** green/yellow with glow — attractive
- **Background:** cool dark tones — never competes with gameplay
- **UI:** white/cyan on semi-transparent dark background

### Resolution Targets
- Ship sprites: 16×16 to 32×32 px
- Enemy sprites: 16×16 to 48×48 px
- Bullet sprites: 4×4 to 8×8 px
- FX sprites: 16×16 to 32×32 px
- UI elements: variable, always readable at 320×180

## Prompt Templates

### Ship Prompt Base
```
pixel art spaceship, top-down view, [COLOR] hull, [DETAIL],
retro arcade style, 32x32 pixels, black background,
1px dark outline, clean silhouette, no anti-aliasing
```

### Enemy Prompt Base
```
pixel art alien [TYPE], top-down view, [COLOR] body,
threatening silhouette, retro arcade style, [SIZE]x[SIZE] pixels,
black background, 1px outline, no anti-aliasing
```

### Pickup Prompt Base
```
pixel art [ITEM], top-down view, glowing [COLOR],
simple readable shape, retro arcade style, 8x8 pixels,
black background, no anti-aliasing
```

## Quality Checklist
- [ ] Readable at target resolution (320×180)
- [ ] Clearly distinguishable silhouette
- [ ] No anti-aliasing (pure pixel art)
- [ ] Palette within defined range
- [ ] Proportions coherent with other assets in the category
- [ ] Clean transparent background

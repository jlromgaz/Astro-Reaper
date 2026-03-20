---
name: generate-pixel-art
description: Skill for generating pixel art assets using AI image generation tools
---

# Generate Pixel Art Skill

This skill guides the generation of pixel art assets for Astro Reaper using AI image generation.

## When to Use
- When a new enemy, weapon, ship, or UI element needs visual assets
- When placeholder sprites need to be replaced with final art
- When creating visual variants of existing assets

## Style Reference
Follow the guidelines in `agents/ai-art-director.md`:
- **Style:** Retro pixel art, arcade space aesthetic (80s/90s)
- **Palette:** Limited (16-24 colors per category)
- **Outline:** 1px dark outline for readability
- **No anti-aliasing** — pure pixel art

## Process
1. Read `agents/ai-art-director.md` for the full style guide and prompt templates
2. Identify the asset type and target size
3. Build a prompt using the templates from the art director agent
4. Generate 3-5 variants using the `generate_image` tool
5. Select the best variant based on readability, consistency, and silhouette clarity
6. Save to `assets/art/[category]/[category]_[name]_[variant].png`
7. Configure Godot import: `filter=false`, `compress=lossless`, `mipmaps=false`

## Prompt Template Quick Reference
```
pixel art [SUBJECT], top-down view, [COLORS/DETAILS],
retro arcade style, [SIZE]x[SIZE] pixels, black background,
1px dark outline, clean silhouette, no anti-aliasing
```

## Size Guide
| Asset Type | Target Size |
|------------|-------------|
| Ship       | 32×32 px    |
| Enemy      | 16×16 to 48×48 px |
| Bullet     | 4×4 to 8×8 px |
| FX         | 16×16 to 32×32 px |
| Pickup     | 8×8 px      |

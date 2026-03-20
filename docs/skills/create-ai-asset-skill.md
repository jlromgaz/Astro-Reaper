# Skill: Create AI Asset

## Overview
Standard procedure for generating visual assets with AI and integrating them into the project.

## Steps

### 1. Define Visual Goal
- **What:** Asset type (ship, enemy, bullet, fx, ui, background)
- **Size:** Target resolution (e.g., 32×32 px)
- **Style:** Retro pixel art, reference the style guide
- **Context:** How it looks in gameplay (scale, layer, animation)

### 2. Build Prompt
Use templates from `agents/ai-art-director.md`:
```
pixel art [SUBJECT], top-down view, [COLORS],
[STYLE DETAILS], retro arcade style, [SIZE]x[SIZE] pixels,
black background, 1px dark outline, no anti-aliasing,
clean silhouette, transparent background
```

### 3. Generate Variants
- Generate 3-5 variants with the same prompt
- Try small prompt variations for diversity
- Document which prompts produced the best results

### 4. Select and Refine
- Choose the best variant based on:
  - [ ] Readability at target resolution
  - [ ] Consistency with other assets in the category
  - [ ] Clear and distinguishable silhouette
  - [ ] Palette within defined range
- Manual touch-up if needed (pixel cleanup)

### 5. Process for Import
- Export as PNG with transparent background
- Resize to exact target dimensions
- Remove any anti-aliasing artifacts
- Verify 1:1 pixel ratio (no fractional pixels)

### 6. Import to Project
Follow `agents/pixel-art-integration.md`:
- Name: `[category]_[name]_[variant].png`
- Location: `assets/art/[category]/`
- Import settings: filter=false, compress=lossless, mipmaps=false

### 7. Document
- Save successful prompts in `docs/art-prompts/[category].md`
- Note which tool/model was used
- Record any manual edits made

## Tools
- Image generation AI (e.g., DALL-E, Midjourney, Stable Diffusion)
- Pixel art editor for cleanup (Aseprite, Piskel, LibreSprite)
- Godot's built-in sprite tools for verification

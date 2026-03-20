# Skill: Fix Performance

## Overview
Optimization checklist for resolving performance issues on Android 2D.

## Diagnostic Steps

### 1. Identify the Bottleneck
- Open Godot Profiler (Debugger → Profiler)
- Check: Is it CPU or GPU bound?
- Check: Which functions take the most time?
- Check: Node count in Scene tree
- Check: Physics body count

### 2. Common Culprits

#### Too Many Nodes
- **Symptom:** Thousands of nodes in scene tree
- **Fix:** Implement object pooling for projectiles, enemies, pickups
- **Target:** Max 200-300 active nodes at any time

#### Too Many Physics Bodies
- **Symptom:** Physics step time is high
- **Fix:** 
  - Simplify collision shapes (circles > polygons)
  - Reduce collision layer interactions
  - Pool and deactivate off-screen bodies
  
#### Draw Calls
- **Symptom:** GPU time is high, many small sprites
- **Fix:**
  - Use sprite atlas / texture atlas
  - Reduce particle count
  - Batch similar sprites on same z-layer

#### GDScript Performance
- **Symptom:** Specific function shows high in profiler
- **Fix:**
  - Cache node references with `@onready`
  - Avoid `get_node()` in `_process()`
  - Use signals instead of polling
  - Minimize array/dictionary operations per frame

### 3. Optimization Checklist
- [ ] Object pooling for projectiles (max ~100)
- [ ] Object pooling for enemies (max ~50)
- [ ] Object pooling for XP pickups (max ~100)
- [ ] Collision layers correctly configured (minimal masks)
- [ ] Off-screen entities deactivated or culled
- [ ] Sprite atlas used for common assets
- [ ] No `get_node()` calls in `_process()` / `_physics_process()`
- [ ] Particle effects limited (max ~5 emitters active)
- [ ] No orphan nodes accumulating
- [ ] Timer-based cleanup for stale entities

### 4. Performance Targets (Android)
```
FPS: 60 stable (min 30)
Node count: < 500
Physics bodies: < 200
Draw calls: < 100
Memory: < 200 MB
```

### 5. Test After Optimization
- [ ] Run feels the same gameplay-wise
- [ ] FPS stable with 50+ enemies on screen
- [ ] No visual artifacts from pooling
- [ ] No crashes from null references (recycled objects)

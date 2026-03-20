# Skill: Bug Triage

## Overview
Standard method for processing, documenting, and resolving bugs.

## Steps

### 1. Reproduce
- Follow reported steps exactly
- Try to find minimum reproduction case
- Note: is it consistent (100%) or intermittent?
- Record Godot console output/errors

### 2. Classify

| Severity | Description | Action |
|----------|-------------|--------|
| **Critical** | Crash, data loss, unplayable | Fix immediately |
| **High** | Core loop broken, wrong behavior | Fix this sprint |
| **Medium** | Visual bug, minor mechanic issue | Fix when convenient |
| **Low** | Cosmetic, edge case, polish | Backlog |

### 3. Isolate
- Identify which system is affected
- Check recent changes to that system (`git log`)
- Create a minimal test case if possible
- Narrow down to specific script/node

### 4. Root Cause Analysis
- **Signal not connected?** → Check `_ready()` connections
- **Null reference?** → Node not found or freed early
- **Wrong value?** → Check resource data files
- **Timing issue?** → `_process` vs `_physics_process` vs signals
- **Collision not working?** → Check layers and masks
- **Visual glitch?** → Check z-index, sprite, animation

### 5. Fix
- Apply the **smallest possible patch**
- Don't refactor unrelated code in the same fix
- Add defensive checks where appropriate
- Document why the fix works (comment if non-obvious)

### 6. Validate
- [ ] Original bug no longer reproduces
- [ ] No regression in related functionality
- [ ] Run core loop regression test (see `agents/qa-playtest.md`)
- [ ] Console clean of errors

### 7. Document
```markdown
## Bug Fix: [title]
**Date:** YYYY-MM-DD
**Severity:** [Critical/High/Medium/Low]
**Root cause:** [brief explanation]
**Fix:** [what was changed]
**Files modified:** [list]
**Risk:** [any follow-up concerns]
```

## Bug Report Template
```markdown
## Bug: [short title]
**Severity:** Critical / High / Medium / Low
**Steps to reproduce:**
1. ...
2. ...
3. ...
**Expected:** ...
**Actual:** ...
**Console errors:** ...
**Frequency:** Always / Sometimes / Rare
**Possible cause:** ...
```

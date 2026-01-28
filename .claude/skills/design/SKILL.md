---
name: good-design
description: Master the impeccable.style design system for creating distinctive, production-grade UI. Reference for all 17 commands and design workflows.
---

# Impeccable Mastery

Design fluency for AI coding tools. This skill provides mastery over the impeccable.style command system.

## Philosophy

Great design prompts require design vocabulary. Impeccable provides designer-specific commands that translate design concepts into actionable prompts—enabling sophisticated design conversations without formal design training.

## Command Reference

### Diagnostic Commands (Start Here)

| Command | Purpose | Leads To |
|---------|---------|----------|
| `/audit` | Technical quality audit: accessibility, performance, theming, responsive | normalize, harden, optimize, adapt, clarify |
| `/critique` | UX and design review: hierarchy, flow, emotional resonance | polish, simplify, bolder, quieter |

**When to use**: Start new design work with `/critique` for UX direction or `/audit` for technical quality.

### Quality Commands

| Command | Purpose | Combines With |
|---------|---------|---------------|
| `/normalize` | Align with design system tokens and patterns | clarify, adapt |
| `/polish` | Final quality pass: alignment, spacing, consistency | (use before shipping) |
| `/optimize` | Performance: loading, rendering, animations, bundle size | harden |
| `/harden` | Resilience: error handling, i18n, text overflow, edge cases | optimize |

**When to use**: `/polish` is always the final step. Use `/harden` + `/optimize` together for production readiness.

### Intensity Commands

| Command | Purpose | Inverse |
|---------|---------|---------|
| `/bolder` | Amplify safe/boring designs—increase visual impact | quieter |
| `/quieter` | Tone down aggressive designs—reduce visual noise | bolder |

**When to use**: After initial design, calibrate intensity based on brand and context.

### Adaptation Commands

| Command | Purpose | Combines With |
|---------|---------|---------------|
| `/clarify` | Improve UX copy, error messages, microcopy, labels | normalize, adapt |
| `/simplify` | Strip to essence—remove unnecessary complexity | quieter, normalize |
| `/adapt` | Different devices, contexts, screen sizes | normalize, clarify |

**When to use**: `/simplify` for feature creep. `/adapt` for responsive work. `/clarify` for confusing UI.

### Enhancement Commands

| Command | Purpose | Combines With |
|---------|---------|---------------|
| `/animate` | Add purposeful motion and micro-interactions | delight |
| `/colorize` | Add strategic color to monochromatic designs | bolder, delight |
| `/delight` | Add personality, joy, and memorable moments | bolder, animate |

**When to use**: After core functionality works. These are polish, not foundation.

### System Commands

| Command | Purpose |
|---------|---------|
| `/teach-impeccable` | One-time setup: gather project design context |
| `/extract` | Create design system elements from existing UI |
| `/onboard` | Design onboarding flows and empty states |

**When to use**: `/teach-impeccable` once per project. `/extract` when patterns emerge.

## Workflows

### New Feature Design

```
1. Build core functionality
2. /critique              → Get UX direction
3. /simplify (if needed)  → Remove complexity
4. /bolder or /quieter    → Calibrate intensity
5. /animate + /delight    → Add personality
6. /polish                → Final pass
```

### Production Hardening

```
1. /audit                 → Identify technical gaps
2. /harden                → Error states, edge cases
3. /optimize              → Performance tuning
4. /adapt                 → Responsive/device support
5. /polish                → Final pass
```

### Design System Alignment

```
1. /normalize             → Apply tokens and patterns
2. /clarify               → Fix copy and labels
3. /extract               → Document reusable patterns
```

### Intensity Calibration

```
Too boring?     → /bolder → /colorize → /delight
Too loud?       → /quieter → /simplify
Just right?     → /polish
```

## Command Combinations

| Goal | Commands |
|------|----------|
| Ship-ready feature | `/critique` → `/harden` → `/optimize` → `/polish` |
| Boring → Interesting | `/bolder` → `/colorize` → `/animate` |
| Complex → Simple | `/simplify` → `/clarify` → `/quieter` |
| Accessible & Robust | `/audit` → `/harden` → `/adapt` |
| First-time UX | `/onboard` → `/clarify` → `/delight` |

## Prefix Convention

Use `/i-` prefix to avoid conflicts with other tools:
- `/i-polish` instead of `/polish`
- `/i-audit` instead of `/audit`

## Integration with Skill Invocation

When invoking impeccable commands programmatically:

```js
Skill({
  skill: "impeccable:polish",
  args: "Review the dashboard component for alignment issues"
})
```

Available skill names:
- `impeccable:audit`, `impeccable:critique`
- `impeccable:normalize`, `impeccable:polish`, `impeccable:optimize`, `impeccable:harden`
- `impeccable:bolder`, `impeccable:quieter`
- `impeccable:clarify`, `impeccable:simplify`, `impeccable:adapt`
- `impeccable:animate`, `impeccable:colorize`, `impeccable:delight`
- `impeccable:teach-impeccable`, `impeccable:extract`, `impeccable:onboard`

## Best Practices

1. **Start diagnostic**: Always begin with `/critique` or `/audit` to understand current state
2. **One command at a time**: Apply commands sequentially, review results between each
3. **Polish last**: `/polish` is always the final step before shipping
4. **Simplify early**: Use `/simplify` before adding enhancements
5. **Test intensity**: Try both `/bolder` and `/quieter` to find the right level
6. **Extract patterns**: When you repeat a design, use `/extract` to codify it

## Anti-Patterns

- Running `/delight` before core UX works
- Skipping `/audit` on production features
- Using `/bolder` when design is already busy
- Applying `/polish` mid-development (save for the end)
- Forgetting `/harden` for user-facing features

# Palette's Journal - Critical Learnings

This journal records critical UX and accessibility learnings specific to this project.

## 2026-01-14 - Icon-Only Button Accessibility
**Learning:** Icon-only buttons (like password visibility toggles) are often missing `tooltip` or `semanticLabel` properties, making them inaccessible to screen readers and confusing for some users.
**Action:** Always add a descriptive `tooltip` to `IconButton` and similar widgets. For toggle buttons, the tooltip should describe the *action* that will occur (e.g., "Show password" when obscured), not just the current state.

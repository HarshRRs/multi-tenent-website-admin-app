# Palette's Journal - Critical Learnings

## 2024-05-24 - Accessibility and Touch Targets
**Learning:** Custom `GestureDetector` based buttons often miss critical accessibility features like semantic labels, focus states, and visual feedback (ripples).
**Action:** Always prefer `Material` + `InkWell` + `Tooltip` for icon-only actions. Ensure touch targets are at least 48x48 logical pixels (or close to it) by adding padding to the `InkWell` child, not just the container.

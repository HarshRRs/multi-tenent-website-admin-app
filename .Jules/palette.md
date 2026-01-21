# Palette's Journal - Critical Learnings

This journal records critical UX and accessibility learnings specific to this project.

## 2024-05-22 - Interactive Element Patterns
**Learning:** Found usage of `GestureDetector` wrapping a `Container` for custom buttons (e.g., delete product on card). This pattern lacks visual feedback (ripple) and accessibility semantics (labels).
**Action:** Replace such patterns with `Material` + `InkWell` + `Tooltip` (or `Semantics`) to ensure both visual delight (ripples) and accessibility (screen reader labels).

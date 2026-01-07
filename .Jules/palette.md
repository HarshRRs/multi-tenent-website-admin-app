# Palette's Journal - Critical Learnings

This journal records critical UX and accessibility learnings specific to this project.

## 2024-05-23 - Destructive Action Confirmation
**Learning:** Users can easily accidentally trigger destructive actions (like deletion) if buttons are placed near other interactive elements.
**Action:** Always wrap destructive actions (delete, reset) in a confirmation dialog or require a "long press" interaction. Use `AppColors.error` (red) for the destructive action button in the dialog to signal danger.

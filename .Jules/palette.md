# Palette's Journal - Critical Learnings

This journal records critical UX and accessibility learnings specific to this project.

## 2024-05-22 - [Missing Tooltips on Icon Buttons]
**Learning:** Flutter's `IconButton` widget does not automatically provide a semantic label for screen readers or a hover tooltip. This makes icon-only buttons inaccessible to users relying on assistive technology.
**Action:** Always provide the `tooltip` property when using `IconButton` to ensure both visual feedback on hover and semantic labeling for accessibility.

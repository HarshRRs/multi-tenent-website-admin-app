# Palette's Journal - Critical Learnings

This journal records critical UX and accessibility learnings specific to this project.

## 2024-05-22 - Reusable Form Components
**Learning:** Custom input components (`CosmicInputField`) often strip native platform features if not explicitly forwarded.
**Action:** Always expose `textInputAction`, `onFieldSubmitted`, and `autofillHints` in wrapper components to ensure keyboard navigation and password managers work.

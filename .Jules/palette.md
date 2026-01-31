# Palette's Journal - Critical Learnings

This journal records critical UX and accessibility learnings specific to this project.

## 2026-01-31 - Mobile Form Accessibility
**Learning:** Custom input components often miss native mobile features like `autofillHints` and `TextInputAction` (Next/Done), significantly degrading the login/signup experience.
**Action:** When creating or auditing form fields, always expose `autofillHints`, `textInputAction`, and `onFieldSubmitted` to wrap `TextFormField`.

# Palette's Journal - Critical Learnings

This journal records critical UX and accessibility learnings specific to this project.

## 2024-05-23 - Login Accessibility
**Learning:** `CustomTextField` component lacks `autofillHints` and `textInputAction` support, leading to direct use of `TextFormField` in Login for better UX.
**Action:** In future refactors, update `CustomTextField` to support these properties to encourage reuse and consistency.

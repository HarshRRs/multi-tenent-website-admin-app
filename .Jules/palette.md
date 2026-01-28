# Palette's Journal - Critical Learnings

This journal records critical UX and accessibility learnings specific to this project.

## 2024-05-22 - Custom Inputs Break Autofill
**Learning:** Reusable input components often hide platform-specific properties like `autofillHints` and `textInputAction`, causing the OS to fail at recognizing login forms. This breaks password manager integration.
**Action:** Always expose `autofillHints`, `textInputAction`, and `onFieldSubmitted` in custom input wrappers to ensure native platform behavior is preserved.

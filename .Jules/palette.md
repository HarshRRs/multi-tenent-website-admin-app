# Palette's Journal - Critical Learnings

This journal records critical UX and accessibility learnings specific to this project.

## 2026-01-27 - Autofill and Keyboard Navigation
**Learning:** Custom form fields wrapping `TextFormField` must explicitly expose `autofillHints`, `textInputAction`, and `onFieldSubmitted` to support native autofill and keyboard navigation (Next/Done). Without these, password managers fail and accessibility suffers.
**Action:** Ensure all custom input components in the design system propagate these properties to the underlying Flutter widget.

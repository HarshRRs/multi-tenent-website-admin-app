# Palette's Journal - Critical Learnings

This journal records critical UX and accessibility learnings specific to this project.

## 2026-01-24 - [Autofill & Keyboard Actions]
**Learning:** Custom form fields (like `CosmicInputField`) must explicitly expose and pass `autofillHints` and `textInputAction` to the underlying `TextFormField`. Without this, users cannot use password managers or keyboard navigation (Next/Done), significantly degrading the mobile experience.
**Action:** Always verify that custom input wrappers include these parameters and wrap form fields in an `AutofillGroup`.

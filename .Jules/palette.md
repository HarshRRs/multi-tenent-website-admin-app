# Palette's Journal - Critical Learnings

This journal records critical UX and accessibility learnings specific to this project.

## 2024-05-22 - Native Form Behavior
**Learning:** Custom form components (like `CosmicInputField`) must expose `autofillHints` and `textInputAction` to support password managers and keyboard navigation. Without these, the user experience is significantly degraded on mobile devices.
**Action:** Always include these properties in the constructor of any custom input wrapper and pass them to the underlying `TextFormField` or `TextField`.

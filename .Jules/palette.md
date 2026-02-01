# Palette's Journal - Critical Learnings

This journal records critical UX and accessibility learnings specific to this project.

## 2026-02-05 - Custom Inputs Missing Platform Interactions
**Learning:** The `CosmicInputField` component was visually polished but lacked standard platform interactions (autofill, keyboard actions), forcing users to manually navigate fields and hindering password managers.
**Action:** All custom form input components must expose `autofillHints`, `textInputAction`, and `onFieldSubmitted` properties to the underlying `TextFormField` to ensure native-like behavior.

# Palette's Journal - Critical Learnings

This journal records critical UX and accessibility learnings specific to this project.

## 2024-05-23 - Enhanced Input Field Component
**Learning:** The custom `CosmicInputField` component lacked accessibility features (autofill, keyboard actions) present in standard widgets, forcing developers to choose between style and function.
**Action:** When creating custom form components, always expose platform interaction properties like `autofillHints` and `textInputAction` to maintain native-like behavior.

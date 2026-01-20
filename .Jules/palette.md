# Palette's Journal - Critical Learnings

This journal records critical UX and accessibility learnings specific to this project.

## 2024-05-24 - Reusable Components & Autofill
**Learning:** The custom `CosmicInputField` component was missing native autofill support (`autofillHints`, `textInputAction`), forcing users to manually type credentials on every login. Custom UI components must expose these platform interaction properties to maintain native-like behavior.
**Action:** When creating reusable form inputs, always include parameters for `autofillHints`, `textInputAction`, and `onFieldSubmitted` to ensure accessibility and ease of use.

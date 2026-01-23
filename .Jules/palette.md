# Palette's Journal - Critical Learnings

This journal records critical UX and accessibility learnings specific to this project.

## 2024-05-23 - Custom Input Fields and Platform Interaction
**Learning:** Custom input components often strip away native platform features like autofill and keyboard actions (next/done), degrading usability significantly on mobile devices.
**Action:** Always expose `autofillHints`, `textInputAction`, and `onFieldSubmitted` in custom input wrappers to ensure native OS integrations (password managers, keyboard navigation) work as expected.

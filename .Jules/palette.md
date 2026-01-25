# Palette's Journal - Critical Learnings

This journal records critical UX and accessibility learnings specific to this project.

## 2024-05-21 - Native Form UX
**Learning:** Flutter forms require `AutofillGroup` and explicit `TextInputAction` configuration to feel "native" and efficient. Users expect the "Next" button to work and passwords to autofill.
**Action:** Always wrap related inputs in `AutofillGroup` and set `textInputAction` + `onFieldSubmitted` for seamless keyboard navigation.

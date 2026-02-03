# Palette's Journal - Critical Learnings

This journal records critical UX and accessibility learnings specific to this project.

## 2024-05-23 - Custom Inputs Block Accessibility
**Learning:** Custom input wrappers (like `CosmicInputField`) that don't expose platform interaction properties (`autofillHints`, `textInputAction`) break native autofill and keyboard navigation flows.
**Action:** When creating or auditing custom form fields, always tunnel these properties to the underlying `TextFormField` to ensure users can use password managers and keyboard shortcuts.

## 2024-05-23 - Design System Consistency
**Learning:** Hardcoded "Cosmic" themes in individual screens clashed with the global "Elite" design system defined in `AppColors`, creating a disjointed user experience.
**Action:** Rely on global `AppTheme` definitions (like `inputDecorationTheme`) rather than creating custom styled widgets for basic components. This ensures a unified look and easier refactoring.

# Palette's Journal - Critical Learnings

This journal records critical UX and accessibility learnings specific to this project.

## 2024-05-23 - Custom Inputs Block Accessibility
**Learning:** Custom input wrappers (like `CosmicInputField`) that don't expose platform interaction properties (`autofillHints`, `textInputAction`) break native autofill and keyboard navigation flows.
**Action:** When creating or auditing custom form fields, always tunnel these properties to the underlying `TextFormField` to ensure users can use password managers and keyboard shortcuts.

## 2024-05-23 - Design System Consistency
**Learning:** Hardcoded "Cosmic" themes in individual screens clashed with the global "Elite" design system defined in `AppColors`, creating a disjointed user experience.
**Action:** Rely on global `AppTheme` definitions (like `inputDecorationTheme`) rather than creating custom styled widgets for basic components. This ensures a unified look and easier refactoring.

## 2024-05-23 - Operational Toggles Visibility
**Learning:** Critical business controls (like Open/Close Store) must be visible on the main Dashboard, not buried in settings.
**Action:** Placed a high-visibility toggle in the Dashboard header to give users immediate control over their business status.

## 2024-05-23 - KDS Uptime
**Learning:** For operational screens like "Live Orders" that act as Kitchen Display Systems (KDS), preventing screen timeout is a critical UX requirement.
**Action:** Maintained `WakelockPlus` integration in the `OrdersScreen` refactor to ensure the device never sleeps while monitoring orders.

## 2024-05-23 - Avoiding Custom Widget Wrappers
**Learning:** Wrapping standard Flutter widgets (like `TextField`, `ElevatedButton`) in custom classes (`CustomTextField`, `CustomButton`) often leads to inconsistent styling and harder maintenance when the global theme changes.
**Action:** Refactored `MenuScreen` and `AddEditProductScreen` to use standard widgets that inherit properties directly from `AppTheme`, reducing code duplication and enforcing the design system automatically.

## 2024-05-23 - Dialog Styling Consistency
**Learning:** Custom styled dialogs often drift from the main app theme.
**Action:** Refactored `ReservationsScreen` to use standard `AlertDialog` and `TimePicker` which automatically pick up the new `AppTheme` colors, ensuring a cohesive experience without manual styling overrides.

# Palette's Journal - Critical Learnings

## 2024-05-22 - [Dynamic Tooltips for Toggle States]
**Learning:** Icon-only buttons that toggle state (like password visibility) need dynamic tooltips to accurately describe the *current* action (e.g., "Show password" vs "Hide password"). Static labels can be confusing or misleading.
**Action:** Always bind `tooltip` properties to the same state variable that controls the icon/functionality.

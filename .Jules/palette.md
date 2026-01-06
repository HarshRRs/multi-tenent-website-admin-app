## 2024-05-23 - Missing Tooltips on IconButtons
**Learning:** Several `IconButton` widgets were missing `tooltip` properties, which makes them inaccessible to screen readers and confusing for mouse users who rely on hover text.
**Action:** Always ensure `IconButton` has a descriptive `tooltip` property. Use it to explain the action (e.g., "Refresh Orders", "Edit Item").

# Palette's Journal - Critical Learnings

## 2024-05-22 - Visual Feedback in Draggable Widgets
**Learning:** Adding visual feedback (ripple effect) to widgets wrapped in `Draggable` is tricky because `Draggable` consumes gestures or sits on top of the content.
**Action:** The reliable pattern is to wrap the content in a `Stack`, then place a transparent `Material` widget with an `InkWell` on top of the content using `Positioned.fill`. This ensures the ripple is visible and the tap is captured, while `Draggable` (wrapping the Stack) handles the drag. Also, always add `Semantics` to the `InkWell` to provide a meaningful label for screen readers, as `Draggable` itself is often opaque to them.

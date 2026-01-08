## 2024-05-24 - Interactive Card Patterns
**Learning:** Cards in a Kanban board are primary interactive elements. Using `GestureDetector` provides no visual feedback, making the UI feel unresponsive. Wrapping content in `Material` + `InkWell` is the standard pattern but requires careful composition with `BoxShadow` and `BorderRadius` (using `ClipRRect`) to ensure the ripple effect is contained but the shadow is not clipped.
**Action:** For all clickable cards, use the `Material` > `InkWell` pattern, separating the shadow container if necessary.

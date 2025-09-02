# Animation Optimization with Sheets

## Problem
When a sheet is presented over an animated visualizer, the animation continues running and consuming CPU/resources even though it's completely hidden.

## Current Behavior
- Visualizer animations use `Timer.scheduledTimer` running at 30 FPS
- Sheets don't trigger `onDisappear` - views remain in hierarchy
- Timers keep firing and consuming CPU even when visualizer is hidden
- Different from page navigation which actually removes views from hierarchy

## Solution: Option 1 - Complete View Removal
**Goal:** Zero CPU usage when sheet is presented (same as page navigation)

### Implementation Approach
```swift
// In MainView - track sheet state
@State private var isSheetPresented = false

// Conditional rendering - completely remove visualizer when sheet is up
if !isSheetPresented {
    VisualizerTabView(...)
}
```

### Benefits
- **Zero CPU usage** when sheet is presented
- **Zero memory** for animations when hidden
- **Complete resource cleanup** - triggers `onDisappear`
- **Same behavior** as navigating to another page
- **Simple implementation** - just conditional rendering

### Alternative: Option 2 - Timer Management
- Invalidate/destroy timers when sheets appear
- Recreate timers when sheets disappear
- More complex but keeps view in hierarchy
- Still uses some resources for view processing

## Recommendation
Use **Option 1** for true zero-resource behavior when sheets are presented over animated content.

## Files to Modify
- `MainView.swift` - Add sheet state tracking
- `HomePage.swift` - Add conditional rendering
- Pass sheet state down to visualizer components

## Key Insight
Sheets cover views but don't remove them from hierarchy. For zero resource usage, actually remove the animated views from the hierarchy when sheets are presented.

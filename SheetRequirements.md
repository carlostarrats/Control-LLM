Problem Statement:
You have two overlapping bottom sheets with different heights (50pt and 100pt) positioned at the bottom of the screen. The 50pt sheet is in front (higher z-index) and the 100pt sheet is behind it (lower z-index). When a user taps on the visible portion of the 100pt sheet that's not covered by the 50pt sheet, you need the 100pt sheet to animate to the front (highest z-index) while the 50pt sheet animates to a lower z-index.
Technical Requirements:

Hit Testing Through Layers: The tap gesture needs to penetrate through the front sheet's bounds to detect taps on the partially visible back sheet
Z-Index Reordering Animation: When the back sheet is tapped, it should smoothly transition to the front layer while the previously front sheet moves behind
Maintain Sheet Heights: Both sheets should retain their original heights (50pt and 100pt) during the reordering animation
Smooth Layering Transition: The animation should visually communicate the depth change, possibly using techniques like:

Scale animation (front sheet slightly scales up)
Shadow/elevation changes
Opacity transitions during the swap
Slide animations that suggest depth reordering



Key Technical Challenges:

Pointer Events: Ensuring tap events can reach the obscured sheet
Stacking Context Management: Properly managing z-index/layer order during animation
Animation Coordination: Synchronizing the forward/backward movement of both sheets
Visual Hierarchy: Making it clear which sheet is active/in-front after the transition
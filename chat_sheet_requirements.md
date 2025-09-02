# Problem Statement

## User Story
As a user, I want the chat to be presented as a sheet on the main screen with specific behavior and constraints.

## Requirements

### 1. Sheet Presentation
- Chat should appear as a sheet overlay on the main screen (not as a separate tab)
- Sheet should initially be 100 points high
- Sheet should be grabbable and expandable to full screen

### 2. Animation Resource Management
- When sheet is at 100pt height: Animation should be visible and running behind the sheet
- When sheet is expanded (raised up): Animation should stop consuming CPU/resources (go away)
- When sheet is dragged down: Animation should return before the sheet reaches 100pt height

### 3. Sheet Dismissal Behavior
- Sheet should only go down to 100pt height, not lower
- Sheet should not disappear completely when dismissed
- Sheet should remain at 100pt height as the minimum state

### 4. UI Layout Constraints
- All existing functionality and styling must remain unchanged
- Input field should be locked at the bottom of the sheet (not at the top)
- All other UI elements should maintain their current positions and styling

### 5. Technical Constraints
- No changes to existing chat functionality
- No changes to existing styling or visual design
- Preserve all current features (file upload, model selection, etc.)
- Maintain current user experience and interactions

## Success Criteria
- Sheet appears at 100pt height on main screen
- Animation stops when sheet is expanded, resumes when collapsed
- Sheet cannot be dismissed below 100pt height
- Input remains at bottom of sheet
- All existing functionality preserved
- No visual or behavioral changes to current chat implementation

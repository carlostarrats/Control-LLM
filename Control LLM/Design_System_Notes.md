# Control LLM Design System Notes

## Coding Rules

### Simplicity First
- **Always start with the simplest, most straightforward approach for ANY problem**
- **Avoid overcomplicating solutions** - if a simple approach works, use it
- **Don't use complex nested structures** when simple ones achieve the same result
- **Test the simple solution first** before adding complexity
- **When in doubt, choose the most direct approach** rather than clever or complex solutions
- **If something isn't working, simplify it** rather than adding more complexity

## Color Palette

### Background Colors
- **Primary Background Gradient:**
  - Top: `#141414` (Dark gray)
  - Bottom: `#1D1D1D` (Lighter dark gray)
  - Used in: MainView background

- **Modal Background:**
  - `#141414` (Dark gray)
  - Used in: TextModalView background

### Text Colors
- **Primary Text:**
  - `#BBBBBB` (Light gray)
  - Used in: Navigation buttons, manual input text, dashed lines

- **Secondary Text:**
  - `#EEEEEE` (Light gray)
  - Used in: Text input field, send button icon

### UI Element Colors
- **Divider:**
  - `#EEEEEE` with 0.6 opacity
  - Used in: TextModalView divider

- **Message Bubbles:**
  - User messages: `#EEEEEE` (light gray background)
  - Assistant messages: `Color.gray.opacity(0.2)` (semi-transparent gray)

- **History Page Elements:**
  - Selected chat background: `#333333` (dark gray)
  - Vertical lines: `#BBBBBB` (1px width)
  - Date separator lines: `#BBBBBB` (2px height)

## Typography

### Font Families
- **Primary Font:** `IBMPlexMono` (Custom monospace font)
  - Regular: `IBMPlexMono-Regular`
  - Medium: `IBMPlexMono-Medium` 
  - Bold: `IBMPlexMono-Bold`

- **Note:** All text in the app should use IBMPlexMono for consistency

### Font Sizes

#### Text Elements
- **Navigation Buttons:** 16pt, Medium weight, Monospaced design
- **Manual Input Text:** 16pt, Medium weight, Monospaced design
- **Manual Input Icon:** 14pt, Medium weight
- **Date Headers:** 12pt, IBMPlexMono
- **Message Content:** 16pt, IBMPlexMono
- **Message Timestamps:** 12pt, IBMPlexMono
- **Text Input Field:** 16pt, IBMPlexMono

#### System UI Elements (TO BE UPDATED)
- **Headlines:** Should use IBMPlexMono, 18pt
- **Body Text:** Should use IBMPlexMono, 16pt
- **Captions:** Should use IBMPlexMono, 12pt
- **Subheadlines:** Should use IBMPlexMono, 16pt
- **Titles:** Should use IBMPlexMono, 20pt
- **Large Titles:** Should use IBMPlexMono, 24pt

#### Error/Loading Views (TO BE UPDATED)
- **Error Icon:** Should use IBMPlexMono, 50pt
- **Error Title:** Should use IBMPlexMono, 18pt
- **Error Message:** Should use IBMPlexMono, 16pt
- **Loading Text:** Should use IBMPlexMono, 16pt

### Font Weights
- **Medium:** Used for most UI text elements
- **Regular:** Used for body text and general content

### Font Designs
- **All text:** IBMPlexMono monospace font for consistency

## Spacing & Layout

### Line Spacing
- **Navigation & Manual Input:** 8px line spacing (24px total - 16px font = 8px spacing)

### Padding
- **Navigation Buttons:** 12px horizontal, 8px vertical
- **Manual Input Button:** 12px horizontal, 8px vertical
- **Text Input Field:** 16px horizontal, 12px vertical
- **Message Bubbles:** 16px horizontal, 10px vertical

### Tracking (Letter Spacing)
- **Navigation & Manual Input:** 0 (no additional letter spacing)

## Usage Patterns

### Main Screen (MainView)
- Background: Dark gradient (`#141414` to `#1D1D1D`)
- Text: Light gray (`#BBBBBB
`)
- Font: 16pt monospaced for navigation, 14pt for icons

### Text Modal (TextModalView)
- Background: Dark (`#141414`)
- Text: Light gray (`#BBBBBB` for headers, `#EEEEEE` for input)
- Font: IBMPlexMono for all text elements

### History Page (HistoryView)
- Background: Dark gradient (`#1D1D1D` to `#141414`)
- Text: Light gray (`#BBBBBB`)
- Font: IBMPlexMono for all text elements
- Spacing: 40px between years, 20px between year and dates, 10px between chat groups
- Chat summaries: Max 2 lines, horizontal padding 4px, vertical padding 8px
- Vertical lines: 1px width, 10px left of centered content
- Date separator lines: 2px height

### Navigation & Settings Screens
- Use IBMPlexMono for all text elements
- Follow iOS design guidelines for form elements

## Consistency Guidelines

1. **Text Colors:** Use `#BBBBBB` for primary text, `#EEEEEE` for interactive elements
2. **Backgrounds:** Use `#141414` for dark backgrounds
3. **Fonts:** Use IBMPlexMono for ALL text elements
4. **Sizes:** 16pt for primary text, 12pt for secondary text, 14pt for icons
5. **Weights:** Medium weight for most text, Regular for body text

## Notes
- The visualizer uses its own color system with hue shifting and should be excluded from this design system
- All colors are defined using hex values for consistency
- Font sizes are specified in points (pt) for clarity
- The app uses a dark theme exclusively
- **IMPORTANT:** All text should use IBMPlexMono font for consistency across the app 
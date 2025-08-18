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

### Primary Brand Colors
- **App Red:** `ColorManager.shared.redColor` (Dynamic red color for brand elements)
  - Used in: FAQ headlines, language codes, accent elements
- **Primary Background:** `#1D1D1D` (Dark gray)
  - Used in: Main backgrounds, sheet backgrounds

### Background Colors
- **Primary Background:** `#1D1D1D` (Dark gray)
  - Used in: MainView, Settings, all sheet backgrounds
- **Secondary Background:** `#141414` (Darker gray)
  - Used in: Alternative backgrounds, modal backgrounds

### Text Colors
- **Primary Text:** `#EEEEEE` (Light gray)
  - Used in: Main text, labels, selected language text, chat input cursor
- **Secondary Text:** `#BBBBBB` (Medium gray)
  - Used in: Subcopy text, descriptive text, secondary information, navigation elements
- **Tertiary Text:** `#666666` (Dark gray)
  - Used in: Disabled text, less prominent information, inactive elements
- **Brand Accent Text:** `ColorManager.shared.redColor` (Dynamic red)
  - Used in: FAQ headlines, language codes, important emphasis text

### Dynamic UI Colors
- **Orange Color:** `ColorManager.shared.orangeColor` (Default: `#F8C762`)
  - Used in: Active states, transcription indicators, success messages, interactive elements
- **Green Color:** `ColorManager.shared.greenColor` (Default: `#3EBBA5`)
  - Used in: Success states, completed actions, positive feedback, apply buttons
- **Purple Color:** `ColorManager.shared.purpleColor` (Default: `#94A8E1`)
  - Used in: User message backgrounds, accent elements, visual indicators

### UI Element Colors
- **Accent Elements:** `ColorManager.shared.redColor`
  - Used in: FAQ headlines, language codes, important UI elements
- **Interactive Elements:** `#EEEEEE`
  - Used in: Buttons, active states, input fields
- **Dividers & Borders:** `#BBBBBB`
  - Used in: Separator lines, borders, visual dividers

## Typography

### Font Families
- **Primary Font:** `IBMPlexMono` (Custom monospace font)
  - Regular: `IBMPlexMono-Regular`
  - Medium: `IBMPlexMono-Medium` 
  - Bold: `IBMPlexMono-Bold`

- **Note:** All text in the app should use IBMPlexMono for consistency

### Font Sizes

#### Text Elements
- **Main Headlines:** 20pt, IBMPlexMono
- **Section Headlines:** 16pt, IBMPlexMono
- **Body Text:** 16pt, IBMPlexMono
- **Subcopy Text:** 14pt, IBMPlexMono
- **Captions:** 12pt, IBMPlexMono
- **Small Text:** 10pt, IBMPlexMono (for language codes, etc.)

#### Specific UI Elements
- **FAQ Headlines:** 16pt, IBMPlexMono, Red color
- **Settings Headlines:** 20pt, IBMPlexMono
- **Language Labels:** 16pt, IBMPlexMono
- **Language Names:** 16pt, IBMPlexMono
- **Language Codes:** 10pt, IBMPlexMono, Red color
- **Chat Input:** 16pt, IBMPlexMono, Cursor color: `#EEEEEE`

### Font Weights
- **Regular:** Used for most UI text elements
- **Medium:** Used for emphasis and important text
- **Bold:** Used sparingly for strong emphasis

### Font Designs
- **All text:** IBMPlexMono monospace font for consistency
- **No fallback fonts:** Always specify IBMPlexMono explicitly

### Font Color Usage
- **Primary Text (`#EEEEEE`):** Main content, labels, active elements, selected states
- **Secondary Text (`#BBBBBB`):** Subcopy, descriptions, secondary information, navigation
- **Tertiary Text (`#666666`):** Disabled states, inactive elements, subtle information
- **Brand Red (`ColorManager.shared.redColor`):** Headlines, emphasis, important UI elements, language codes
- **Orange (`ColorManager.shared.orangeColor`):** Active states, transcription indicators, success messages
- **Green (`ColorManager.shared.greenColor`):** Success states, completed actions, positive feedback
- **Purple (`ColorManager.shared.purpleColor`):** User message backgrounds, accent elements, visual indicators
- **Interactive Elements:** Use `#EEEEEE` for active states and `#BBBBBB` for inactive states

## Spacing & Layout

### Standard Spacing
- **Section Spacing:** 20px between major sections
- **Element Spacing:** 16px between related elements
- **Compact Spacing:** 8px between closely related elements
- **Header Spacing:** 8px below headers, 12px above content

### Padding Standards
- **Sheet Content:** 20px horizontal padding
- **Section Content:** 16px horizontal padding
- **Element Padding:** 8px-16px depending on context
- **Button Padding:** 12px horizontal, 8px vertical

### Layout Principles
- **Flexible Layouts:** Use flexible spacing methods instead of hard-coded values
- **Responsive Design:** Adapt to different screen sizes
- **Consistent Margins:** Maintain consistent spacing patterns

## UI Treatments

### Sheets & Modals
- **Grabber:** Always include grabber at top of sheets
- **Close Button:** X button positioned top-right
- **Header Alignment:** Left-aligned headers for consistency
- **Background:** `#1D1D1D` with proper safe area handling

### Buttons & Interactive Elements
- **Action Buttons:** Always visible but disabled until changes are made
- **Button States:** Clear visual feedback for enabled/disabled states
- **Touch Targets:** Minimum 44pt touch targets

### Visual Elements
- **Language Codes:** Red color (`ColorManager.shared.redColor`) for emphasis
- **FAQ Headlines:** Red color for visual hierarchy
- **Descriptive Text:** Centered alignment with proper spacing
- **Icons:** System SF Symbols with consistent sizing

## iOS Shortcuts Integration

### Design Principles
- **No Visible UI:** Pure background functionality
- **Auto-Discovery:** Actions appear automatically in Shortcuts app
- **Seamless Integration:** No additional setup required

### Implementation Details
- **App Intents Framework:** Modern iOS 16+ integration
- **Background Execution:** Full background processing support
- **Error Handling:** User-friendly error messages for Shortcuts
- **Response Formatting:** Optimized for automation workflows

## Usage Patterns

### Main Screen (MainView)
- Background: `#1D1D1D`
- Text: `#EEEEEE` for primary, `#BBBBBB` for secondary
- Font: IBMPlexMono for all text elements

### Settings Screens
- Background: `#1D1D1D`
- Headers: 20pt IBMPlexMono
- Subcopy: 14pt IBMPlexMono with 12px bottom padding
- Section spacing: 20px between major sections

### FAQ Screen
- Headlines: 16pt IBMPlexMono in red color
- Body text: 14pt IBMPlexMono
- Section spacing: 20px between groupings
- Background: `#1D1D1D`

### Language Screens
- Language codes: 10pt IBMPlexMono in red color
- Full language names: Expanded abbreviations for clarity
- Consistent spacing with other settings screens

## Consistency Guidelines

1. **Colors:** Use `ColorManager.shared.redColor` for brand elements, `#EEEEEE` for primary text
2. **Backgrounds:** Use `#1D1D1D` for main backgrounds
3. **Fonts:** Use IBMPlexMono for ALL text elements without exception
4. **Spacing:** Use 20px for major sections, 16px for elements, 8px for compact spacing
5. **Alignment:** Left-align headers, center descriptive text appropriately

## Notes
- The visualizer uses its own color system with hue shifting and should be excluded from this design system
- All colors are defined using hex values or ColorManager for consistency
- Font sizes are specified in points (pt) for clarity
- The app uses a dark theme exclusively
- **IMPORTANT:** All text must use IBMPlexMono font for consistency across the app
- iOS Shortcuts integration is purely functional with no visible UI elements
- Language codes and FAQ headlines use the app's red color for emphasis

## Visualizer Color System (Separate from Main Design System)
- **Primary Visualizer Colors:** `#FF00D0` (Magenta), `#D20001` (Red), `#8B0000` (Dark Red)
- **Background Colors:** `#5D0C14` (Dark Red-Brown)
- **Hue Shifting:** Dynamic color changes based on user interaction
- **Note:** These colors are managed separately and not part of the main UI color system 
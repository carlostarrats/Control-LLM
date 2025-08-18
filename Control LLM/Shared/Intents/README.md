# iOS Shortcuts Integration for Control LLM

This document explains how the iOS Shortcuts integration works in Control LLM and how users can utilize it.

## Overview

Control LLM now includes full iOS Shortcuts integration using the modern App Intents framework. This allows users to create automated workflows that can interact with the app without needing to open it manually.

## Features

### 1. Send Message Intent
- **Purpose**: Send a message to the LLM and get a response
- **Parameters**: 
  - Message text (required)
  - Recipient identifier (optional, defaults to "Default")
- **Use Cases**: 
  - Quick questions when you're busy
  - Integration with other automation workflows
  // Voice commands removed

### 2. Chain Messages Intent
- **Purpose**: Send multiple messages with configurable delays between them
- **Parameters**:
  - Array of messages (required)
  - Array of delays in seconds (optional, defaults to 1 second)
- **Use Cases**:
  - Multi-step conversations
  - Automated testing scenarios
  - Complex workflow automation

### 3. System Prompt Steering Intent
- **Purpose**: Modify app behavior via system prompt changes
- **Parameters**:
  - Prompt text (required)
  - Behavior type (optional, defaults to "general")
- **Use Cases**:
  - Dynamic personality changes
  - Context switching
  - Behavior customization

## How It Works

### Automatic Discovery
- Actions automatically appear in the Shortcuts app under "Apps" → "Control LLM"
- iOS suggests shortcuts based on your usage patterns
- No manual setup required - just open Shortcuts and start building

### Background Execution
- All intents can run in the background
- No need to keep the app open
- Perfect for automation workflows

### Integration Points
The app automatically donates intents when you perform actions, helping iOS learn your patterns and suggest relevant shortcuts.

## Usage Examples

### Basic Message Shortcut
1. Open Shortcuts app
2. Tap "+" to create a new shortcut
3. Search for "Control LLM"
4. Choose "Send Message"
5. Enter your message
6. Run the shortcut

### Advanced Workflow
1. Create a shortcut that:
   - Gets the current weather
   - Sends it to Control LLM asking for activity suggestions
   - Processes the response
   - Adds it to your calendar

// Voice commands section removed

## Technical Implementation

### App Intents Framework
- Uses iOS 16+ App Intents (modern replacement for Intents framework)
- Automatic metadata generation
- Built-in localization support
- No manual Info.plist configuration needed

### Services Architecture
- `ShortcutsService`: Core service for handling shortcut requests
- `ShortcutsIntegrationHelper`: Helper for integrating with existing app functionality
- `ControlLLMAppShortcuts`: App shortcuts provider for iOS integration

### Background Processing
- Automatic background task registration
- Error handling and user-friendly error messages
- Response formatting for optimal Shortcuts integration

## Requirements

- iOS 16.0 or later
- Control LLM app installed
- Shortcuts app (built into iOS)

## Privacy & Security

- All processing happens on-device
- No data is sent to external servers
- Shortcuts only access the functionality you explicitly grant
- App maintains the same privacy model as the main app

## Troubleshooting

### Shortcuts Not Appearing
- Ensure you're running iOS 16.0+
- Try restarting the Shortcuts app
- Check that Control LLM has necessary permissions

### Background Execution Issues
- Ensure background app refresh is enabled
- Check that the app has necessary background modes
- Verify Siri permissions are granted

### Performance Issues
- Complex shortcuts may take longer to execute
- Consider breaking large workflows into smaller parts
- Use appropriate delays for chained messages

## Future Enhancements

Potential areas for expansion:
- More specialized intents for specific use cases
- Integration with other automation platforms
- Advanced parameter types and validation
- Custom response formatting options

## Support

For issues or questions about the Shortcuts integration:
1. Check this documentation first
2. Verify iOS version compatibility
3. Test with simple shortcuts before complex workflows
4. Check app permissions and settings

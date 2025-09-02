# Qwen Model Gap Fix Requirements

## Current State
- Qwen model currently does NOT show its internal thinking content ✅
- Qwen model currently DOES show the `<think>` and `</think>` tags ✅
- Qwen model currently HAS a visual gap issue ❌

## Requirements
1. **Keep thinking tags visible** - The `<think>` and `</think>` tags must remain visible in the output
2. **Keep thinking content hidden** - The internal thinking content between tags must remain hidden
3. **Eliminate the visual gap** - Remove the gap that appears in the output

## What NOT to do
- Do NOT remove the thinking tags completely
- Do NOT show the internal thinking content
- Do NOT create additional complexity

## Expected Behavior
- User sees: `<think></think>Hello world` (no gap)
- User does NOT see: `<think>internal reasoning</think>Hello world`
- User does NOT see: `<think></think>\n\nHello world` (with gap)

## Technical Approach
- Keep the `<think>` and `</think>` tags visible
- Remove only the content between the tags (including newlines that cause gaps)
- Use state tracking to know when we're inside thinking tags
- Suppress all content (including newlines) while in thinking mode

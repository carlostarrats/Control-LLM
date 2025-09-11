# Generation Cancellation Investigation Plan

## Problem Statement
**Core Issue**: LLM generation is being cancelled prematurely on restart, preventing responses. This doesn't happen on first run.

**Evidence**: 
- Logs show "Generated 23 tokens" then "Generation cancelled"
- User sees thinking dots but no response on restart
- First run works perfectly

## Investigation Plan

### Phase 1: Identify Cancellation Triggers
**Goal**: Find what specifically calls `stopGeneration()` after restart but not on first run

**Approach**:
1. **Enhanced Call Stack Logging**
   - Add call stack logging to ALL `stopGeneration()` entry points
   - Track the exact sequence of calls that lead to cancellation
   - Compare restart vs first run call stacks

2. **State Comparison Analysis**
   - Log all state variables at app startup (first run vs restart)
   - Compare `isProcessing`, `isModelLoaded`, `currentModelFilename` states
   - Identify any state differences that could trigger cancellation

3. **Timing Analysis**
   - Add timestamps to all generation lifecycle events
   - Track time between generation start and cancellation
   - Identify if cancellation happens at a specific time interval

**Files to Modify**:
- `ChatViewModel.swift` - Add enhanced logging to `stopGeneration()`
- `HybridLLMService.swift` - Add enhanced logging to `stopGeneration()`
- `LLMService.swift` - Add logging to all cancellation paths
- `LlamaCppBridge.mm` - Add logging to C++ cancellation functions

### Phase 2: Restart vs First Run Differences
**Goal**: Identify what's different about the restart scenario

**Approach**:
1. **App Lifecycle State Tracking**
   - Log app state transitions (background/foreground, launch/restart)
   - Track if app is in "cold start" vs "warm restart" mode
   - Compare initialization sequences

2. **Model Loading State Analysis**
   - Track model loading process on first run vs restart
   - Compare model state flags between scenarios
   - Identify if model thinks it's loaded when it's not

3. **Memory/Context State Comparison**
   - Log memory allocation/deallocation patterns
   - Track context creation/destruction
   - Compare Metal/GPU memory states

**Files to Investigate**:
- `Control_LLMApp.swift` - App initialization
- `MainView.swift` - View lifecycle
- `LLMService.swift` - Model loading logic
- `LlamaCppBridge.mm` - Context management

### Phase 3: Automatic Cancellation Sources
**Goal**: Find what automatically triggers cancellation without user interaction

**Approach**:
1. **Timer-Based Cancellation Detection**
   - Add logging to any timer-based operations
   - Track if timeouts are triggering cancellation
   - Identify if restart changes timing behavior

2. **Background Task Cancellation**
   - Log background task management
   - Track if app lifecycle events trigger cancellation
   - Compare background behavior between scenarios

3. **Error-Based Cancellation**
   - Add comprehensive error logging
   - Track if errors occur during restart that don't occur on first run
   - Identify if error handling triggers cancellation

4. **State Validation Cancellation**
   - Log all state validation checks
   - Track if restart causes validation failures
   - Identify if validation triggers cancellation

**Files to Investigate**:
- `LLMService.swift` - Error handling and validation
- `HybridLLMService.swift` - Service orchestration
- `ChatViewModel.swift` - State management
- All files with timer/background task logic

## Implementation Strategy

### Step 1: Comprehensive Logging Infrastructure
**Duration**: 30 minutes
**Action**: Add detailed logging to all cancellation entry points
**Deliverable**: Enhanced logs showing exact cancellation triggers

### Step 2: State Comparison Analysis
**Duration**: 45 minutes  
**Action**: Log and compare all relevant state variables between scenarios
**Deliverable**: State difference report between first run and restart

### Step 3: Timing and Lifecycle Analysis
**Duration**: 30 minutes
**Action**: Add timing logs to track generation lifecycle
**Deliverable**: Timing analysis showing when cancellation occurs

### Step 4: Test and Analyze
**Duration**: 15 minutes
**Action**: Test both scenarios and analyze logs
**Deliverable**: Root cause identification

## Success Criteria

### Phase 1 Success:
- [ ] Identify exact function/line that calls `stopGeneration()` on restart
- [ ] Understand the call sequence leading to cancellation
- [ ] Compare restart vs first run call stacks

### Phase 2 Success:
- [ ] Identify key differences between restart and first run scenarios
- [ ] Understand why restart triggers different behavior
- [ ] Map the state differences to cancellation triggers

### Phase 3 Success:
- [ ] Find the automatic cancellation source
- [ ] Understand why it only triggers on restart
- [ ] Identify the fix needed to prevent premature cancellation

## Expected Outcomes

**Best Case**: Find a simple state flag or condition that's different on restart
**Likely Case**: Discover a timing issue or race condition specific to restart
**Worst Case**: Identify a complex interaction between multiple systems

## Risk Mitigation

**Risk**: Adding too much logging could impact performance
**Mitigation**: Use conditional logging that can be easily disabled

**Risk**: Logs might not capture the exact moment of cancellation
**Mitigation**: Add logging at multiple levels (UI, service, C++ bridge)

**Risk**: The issue might be intermittent
**Mitigation**: Test multiple restart scenarios to ensure consistent reproduction

## Next Steps After Investigation

1. **If Simple State Issue**: Fix the state flag/condition
2. **If Timing Issue**: Adjust timing or add synchronization
3. **If Complex Interaction**: Design targeted fix based on findings
4. **If No Clear Cause**: Escalate to deeper system-level investigation

## Files to Create/Modify

### New Files:
- `Control LLM/Generation_Cancellation_Investigation_Plan.md` (this file)

### Modified Files:
- `ChatViewModel.swift` - Enhanced cancellation logging
- `HybridLLMService.swift` - Enhanced cancellation logging  
- `LLMService.swift` - Enhanced cancellation logging
- `LlamaCppBridge.mm` - Enhanced cancellation logging
- `Control_LLMApp.swift` - App lifecycle logging
- `MainView.swift` - View lifecycle logging

## Timeline

**Total Estimated Time**: 2 hours
- Investigation setup: 30 minutes
- Testing and analysis: 60 minutes  
- Root cause identification: 30 minutes

**Target**: Complete investigation and identify root cause within 2 hours

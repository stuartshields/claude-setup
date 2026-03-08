#!/bin/bash
# PermissionRequest hook — plays a sound when Claude needs permission approval.
# Receives JSON on stdin with tool_name, tool_input, permission_suggestions.
# Exit 0 with no output = default behavior (show permission dialog).
# Exit 0 with JSON hookSpecificOutput = auto-approve/deny.

# Play notification sound (non-blocking)
afplay /System/Library/Sounds/Glass.aiff &

exit 0

#!/bin/bash
# InstructionsLoaded audit hook - logs which instruction files load and why.
# Observation only (exit 0) - cannot block or modify loading.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.file_path')
LOAD_REASON=$(echo "$INPUT" | jq -r '.load_reason')
MEMORY_TYPE=$(echo "$INPUT" | jq -r '.memory_type')
GLOBS=$(echo "$INPUT" | jq -r '.globs // empty')
TRIGGER=$(echo "$INPUT" | jq -r '.trigger_file_path // empty')

LINE="[$(date '+%H:%M:%S')] $MEMORY_TYPE: $FILE_PATH (reason: $LOAD_REASON)"
[ -n "$GLOBS" ] && LINE="$LINE globs=$GLOBS"
[ -n "$TRIGGER" ] && LINE="$LINE trigger=$TRIGGER"

echo "$LINE" >> ~/.claude/instruction-audit.log
exit 0

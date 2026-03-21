# Claude Code launch shortcuts for Bash/Zsh
# Source this from ~/.bashrc or ~/.zshrc:
#   source ~/.claude/scripts/claude-shortcuts.bash

# c       = lean mode (context7 only, no Figma plugin)
# cf      = full mode (all MCPs + Figma plugin)
# Both support session resume: c <session-id> or cf <session-id>

# Lean MCP config: only context7 (lightweight, always useful for docs lookups)
_CLAUDE_LEAN_MCP='{"mcpServers":{"context7":{"type":"stdio","command":"npx","args":["-y","@upstash/context7-mcp@latest"]}}}'

cf() {
	claude plugin enable figma@claude-plugins-official > /dev/null 2>&1
	if [ -n "$1" ]; then
		claude --resume "$1"
	else
		claude
	fi
}

c() {
	claude plugin disable figma@claude-plugins-official > /dev/null 2>&1
	if [ -n "$1" ]; then
		claude --resume "$1" --strict-mcp-config --mcp-config "$_CLAUDE_LEAN_MCP"
	else
		claude --strict-mcp-config --mcp-config "$_CLAUDE_LEAN_MCP"
	fi
}

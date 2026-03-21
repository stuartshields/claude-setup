# Claude Code launch shortcuts for Fish shell
# Source this from ~/.config/fish/config.fish:
#   source ~/.claude/scripts/claude-shortcuts.fish

# c       = lean mode (context7 only, no Figma plugin)
# cf      = full mode (all MCPs + Figma plugin)
# Both support session resume: c <session-id> or cf <session-id>

# Lean MCP config: only context7 (lightweight, always useful for docs lookups)
set -g _claude_lean_mcp '{"mcpServers":{"context7":{"type":"stdio","command":"npx","args":["-y","@upstash/context7-mcp@latest"]}}}'

function cf
	claude plugin enable figma@claude-plugins-official > /dev/null 2>&1
	if test (count $argv) -gt 0
		claude --resume $argv[1]
	else
		claude
	end
end

function c
	claude plugin disable figma@claude-plugins-official > /dev/null 2>&1
	if test (count $argv) -gt 0
		claude --resume $argv[1] --strict-mcp-config --mcp-config $_claude_lean_mcp
	else
		claude --strict-mcp-config --mcp-config $_claude_lean_mcp
	end
end

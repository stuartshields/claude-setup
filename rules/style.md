<!-- Last updated: 2026-03-22T11:46+11:00 -->

# Style & Code Quality

## Style
- **Tabs only** for indentation.
- **Tab Handling for Edit Tool:** Read tool shows tabs as visual spaces. The actual file has literal `\t`. When using Edit:
	1. `old_string` MUST use literal tab characters — spaces fail.
	2. `new_string` MUST also use literal tabs.
	3. If Edit fails on indented line, fix tab/space mismatch — do not fall back to sed/awk/python.
	4. When unsure, start `old_string` at first non-whitespace character.
- **Clean code:** Use `console.error` for debug output (never `console.log` — blocked by hook). Keep lines clean of trailing whitespace. Let errors propagate unless at a system boundary.

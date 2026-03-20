# Style & Code Quality

## Style
- **Tabs only** for indentation.
- **Tab Handling for Edit Tool:** Read tool shows tabs as visual spaces. The actual file has literal `\t`. When using Edit:
	1. `old_string` MUST use literal tab characters - spaces fail.
	2. `new_string` MUST also use literal tabs.
	3. If Edit fails on indented line, fix tab/space mismatch - do not fall back to sed/awk/python.
	4. When unsure, start `old_string` at first non-whitespace character.
- **Clean code:** No `console.log`, no trailing whitespace, no redundant try/catch.

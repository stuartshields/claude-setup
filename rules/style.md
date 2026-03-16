# Style & Code Quality

## IMPORTANT: Full Fidelity
- **Provide complete, syntactically correct code.** Placeholder comments like `// ... rest of code` are prohibited.
- **Resolve all imports.** No phantom functions or unimplemented references.
- **Verify API methods and config options exist** before using them. "Looks right" is not verification — check docs (WebSearch/context7) or ask.

## Style
- **Tabs only** for indentation.
- **Tab Handling for Edit Tool:** Read tool shows tabs as visual spaces. The actual file has literal `\t`. When using Edit:
	1. `old_string` MUST use literal tab characters — spaces fail.
	2. `new_string` MUST also use literal tabs.
	3. If Edit fails on indented line, fix tab/space mismatch — do not fall back to sed/awk/python.
	4. When unsure, start `old_string` at first non-whitespace character.
- **Clean code:** No `console.log`, no trailing whitespace, no redundant try/catch.
- **Grep before reading.** Scan the repo with Grep to find relevant code before reading entire files.

# Style & Code Quality

## Anti-Lazy & Full Fidelity
- **No Truncation:** Placeholder comments like `// ... rest of code` are strictly prohibited.
- **Complete Blocks:** Provide full, syntactically correct file contents for new or refactored code.
- **Verification:** Ensure all imports are resolved and no "phantom" functions are left unimplemented.
- **No Hallucinated Code:** Never use API methods, config options, function signatures, or class names that you haven't verified exist. If unsure, check the docs (WebSearch/context7) or ask the user. "Looks right" is not verification.

## Style

```javascript
// Correct style: ES6, tabs, destructuring, async/await
import { fetchUser } from './services/user.js';

const getProfile = async (id) => {
	const user = await fetchUser(id);
	return { name: user.name, role: user.role };
};
```

- **Tabs Only** for indentation.
- **Tab Handling for Edit Tool:** The Read tool displays tab characters as visual spaces after the `→` line marker. The actual file contains literal `\t` bytes. When using the Edit tool:
	1. The `old_string` MUST use literal tab characters to match the file — spaces will fail with "String to replace not found."
	2. The `new_string` MUST also use literal tab characters for indentation.
	3. If an Edit fails on an indented line, the cause is almost certainly a tab/space mismatch. Do NOT fall back to `sed`, `awk`, `python3`, or Bash workarounds — fix the `old_string` to use tabs and retry.
	4. When unsure about a file's whitespace, start `old_string` at the first non-whitespace character on the line to avoid the mismatch entirely.
- **Clean Code:** No `console.log`, no trailing whitespace, no redundant try/catch blocks that hide errors.
- **Token Efficiency:** Use the Grep tool to scan the repo before reading entire files to save context.

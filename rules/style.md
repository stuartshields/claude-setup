# Style & Code Quality

## Anti-Lazy & Full Fidelity
- **No Truncation:** Placeholder comments like `// ... rest of code` are strictly prohibited.
- **Complete Blocks:** Provide full, syntactically correct file contents for new or refactored code.
- **Verification:** Ensure all imports are resolved and no "phantom" functions are left unimplemented.
- **No Hallucinated Code:** Never use API methods, config options, function signatures, or class names that you haven't verified exist. If unsure, check the docs (WebSearch/context7) or ask the user. "Looks right" is not verification.

## Style
- **Tabs Only** for indentation.
- **Clean Code:** No `console.log`, no trailing whitespace, no redundant try/catch blocks that hide errors.
- **Token Efficiency:** Use the Grep tool to scan the repo before reading entire files to save context.

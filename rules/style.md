<!-- Last updated: 2026-05-19T12:00+10:00 -->

# Style & Code Quality

## Style
- **Tabs only** for indentation. Hooks enforce this at write time and surface indent mismatches on Edit with corrective feedback (`tab-edit-guard.sh`, `tab-read-reminder.sh`). When unsure, start `old_string` at the first non-whitespace character.
- **Clean code:** Use `console.error` for debug output (never `console.log` — blocked by hook). Keep lines clean of trailing whitespace. Let errors propagate unless at a system boundary.

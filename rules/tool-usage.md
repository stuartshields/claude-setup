<!-- Last updated: 2026-03-23T10:30+11:00 -->

# Tool Usage

## Edit Tool
- **Edit retry limit.** If the Edit tool fails twice on the same target, do not retry with whitespace variations. Re-read the file to get the actual content, then use the exact text from the fresh read. If it still fails, use Write to replace the full file.
- **Read before Edit, always.** The file on disk may differ from what you expect — formatters, hooks, or prior edits may have changed it. Edit with stale content fails silently or matches the wrong location.
- **Prefer Edit over Write for existing files.** Edit sends only the diff. Write replaces the entire file and risks losing concurrent changes.

## Bash Tool
- **Do not use Bash when a dedicated tool exists.** Read instead of cat. Edit instead of sed. Grep instead of grep/rg. Glob instead of find. Dedicated tools give the user visibility into what you're doing.
- **Do not retry failing Bash commands in a loop.** Diagnose the failure, don't re-run with minor variations. If a command fails twice, explain what happened and ask.

## Search Tools
- **WebSearch/WebFetch have a budget per question.** Three searches and two page fetches. If you haven't found the answer, summarise what you learned and ask the user. Do not rephrase the same query hoping for better results.

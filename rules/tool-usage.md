<!-- Last updated: 2026-03-26T12:00+11:00 -->

# Tool Usage

## Edit Tool
- **Edit retry limit.** If Edit fails twice on the same target, re-read the file for actual content. If it still fails, use Write to replace the full file.
- **Read before Edit, always.** Hooks may modify file contents after Write — the file on disk may differ from what you expect.

## Search Tools
- **WebSearch/WebFetch budget: 3 searches + 2 fetches per question.** If you haven't found the answer, summarise what you learned and ask the user.

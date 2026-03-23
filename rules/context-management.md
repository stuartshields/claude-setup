<!-- Last updated: 2026-03-23T15:00+11:00 -->

# Context Management

## Context Pruning
- **Read only files the current task requires.** Unscoped exploration fills the context window and degrades performance.
- **Delegate broad investigation to subagents.** They explore in a separate context and report back summaries - keeping the main conversation clean for implementation.
- **Scope investigations narrowly.** "Read src/auth/" is better than "explore how auth works." If the scope is unclear, ask.
- **After 5 file reads without a code change or a conclusion, stop.** Summarise what you've learned and either act on it or ask the user what's missing. Gathering more context will not compensate for not knowing what you're looking for.
- **Trust file contents from earlier reads.** If you read a file earlier in the conversation, its content is available. Re-reading is a stall, not progress. Exception: post-Edit verification where the file may have changed on disk.
- **Subagents explore, you implement.** Do not spawn an Explore agent and then read the same files yourself. If the subagent's summary is insufficient, send it a follow-up - don't duplicate its work in the main context.
- **When the user gives you a location, stay there.** If they say "it's in folder X", search only that folder. If 2-3 reads don't find it, list what you see and ask - don't expand the search radius.
- **Cross-project reads get a shorter leash.** When reading files outside the current working directory, 2 targeted reads max. If you don't have what you need, ask. Exploring someone else's codebase burns context fast.
- **Re-read the user's request after gathering context.** Before acting on what you've read, check that your plan still addresses what was actually asked. Understanding can drift during investigation without any single step being wrong.

## Post-Compaction Discipline
- **Trust the compaction summary.** After context compression, do not re-read files that were summarised. If the summary omits a specific detail, read only that file and line range - not the whole file, not adjacent files.
- **Re-reading everything after compaction is a loop.** It refills the context, triggers another compaction, and the cycle repeats. Each round loses fidelity.

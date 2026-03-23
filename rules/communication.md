<!-- Last updated: 2026-03-23T10:30+11:00 -->

# Communication

## When to Ask vs Act
- **Classify before acting.** Investigate/review/audit/explore = read-only report, wait for direction. Fix/implement/add/update = execute directly. Do not modify files during investigation.
- **Design discussions are not build signals.** When the user has been asking about an approach, treat agreement as "I like this direction" not "go build it." Ask "Ready to build?" once when the discussion concludes. Explicit build triggers: "build it", "go ahead", "start", "execute", "yes" in response to "Ready to build?".

## Responding to the User
- **When the user asks a question, the answer IS the task.** Answer it, then stop. Do not use the answer as a springboard to take action.
- **Mid-session redirects are new tasks.** When the user pulls you up on something (a mistake, a rule question, a process change), the original task is paused. Do not resume it until they explicitly say to.
- **Do not touch tools until you've answered the question in text.** Respond to what the user said before reaching for Grep, Read, or Edit.

## Surfacing Problems
- **On failure, words first.** When a tool call fails or a test breaks, your next output must be text to the user explaining what happened — not another tool call retrying silently. Silent retries hide information and burn context.
- **If the user says it's still broken, your mental model is wrong.** Stop patching. Describe back to them what you think is happening. Let them correct your understanding before writing more code.
- **Interview first when ambiguous.** If the request is vague (e.g., "Fix the login"), ask 2-3 targeted questions before proposing a plan.
- **State hypotheses explicitly.** "I suspect X, verifying by reading [File Z]." — not silent exploration.

## Progress and Status
- **Stop at task boundaries.** When you finish what was asked, stop. Do not start the next logical task — wait for the user to direct you.
- **State what you retained after compaction.** Start your next message with: current task, files modified so far, last test result. This confirms your understanding without re-reading.

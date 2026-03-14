---
title: Agents
nav_order: 6
---

## Agents

Rules apply to every conversation. But some tasks need a different personality entirely - a code reviewer that only reads and never writes, a security auditor that can use a cheaper model, a WordPress specialist that only loads PHP-related tools. Rules can't do that. Agents can.

Agents are markdown files with YAML frontmatter that define specialist subagents. Claude can delegate tasks to them when the work matches. The agent runs with its own instructions, its own tool restrictions, and optionally its own model. It reports back when done.

**Tip:** Run `/agents` to create agents interactively, or use `--agents` CLI flag for session-scoped agents.

### Frontmatter fields

| Field | What it does |
|-------|-------------|
| `name` | Lowercase-with-hyphens identifier. How you reference the agent. (Required) |
| `description` | Tells Claude when to delegate to this agent. Quality matters - a vague description means missed delegations. (Required) |
| `tools` | Comma-separated list of allowed tools. Omit to inherit all tools. |
| `disallowedTools` | Tools to deny - removed from inherited or specified list. |
| `model` | `sonnet`, `opus`, `haiku`, or `inherit`. Default: inherit. |
| `permissionMode` | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan`. Controls permission prompts. |
| `maxTurns` | Limits agentic turns. Prevents runaway agents from looping. |
| `skills` | Skills to load into the subagent's context at startup. |
| `mcpServers` | MCP servers available to this subagent. |
| `hooks` | Lifecycle hooks scoped to this subagent. |
| `memory` | Persistent memory scope: `user`, `project`, or `local`. |
| `background` | Set to `true` to always run as a background task. Default: `false`. |
| `isolation` | Set to `worktree` to run in a temporary git worktree. |

### Example: code-reviewer.md

The clearest example of why you'd want an agent instead of a rule. The code reviewer needs to:

1. Be read-only - it should never write or edit files, only report
2. Run on `sonnet` (lighter model) since reviewing doesn't need the most capable model
3. Have a 25-turn limit to prevent infinite review loops

Here's its frontmatter:

```yaml
---
name: code-reviewer
description: General-purpose code reviewer. Examines code for logical errors, race conditions, edge cases, type mismatches, and CLAUDE.md compliance. Read-only - never modifies code. Works on specific files by default; supports git diff review when explicitly requested.
tools: Read, Grep, Glob, Bash
model: sonnet
maxTurns: 25
---
```

Four tools only: `Read`, `Grep`, `Glob`, `Bash`. No `Write`, no `Edit`. The model declaration (`sonnet`) makes every code review cheaper than if it ran on `opus`. The `maxTurns: 25` means it can do a thorough review without risking an infinite loop.

A rule can say "never modify code when reviewing." An agent makes it structurally impossible.

### Where agent files live

This repo's `agents/` directory maps to `~/.claude/agents/`. These are **user-global agents** - available across every project.

For **project-specific agents**, put them in `.claude/agents/` at the project root. Project agents are available only in that project. If you have a database migration specialist that only makes sense for one codebase, put it there rather than polluting your global agent list.

### Rules vs agents: when to use which

| Use a rule when... | Use an agent when... |
|-------------------|---------------------|
| It's a constraint that always applies | It's a task you'd delegate to a specialist |
| "Always use tabs" | "Review this code for bugs" |
| "Never skip tests" | "Audit this for security issues" |
| "No console.log" | "Rewrite this as a WordPress plugin" |

Rule of thumb: if it's a style preference or a guardrail → rule. If it's a distinct task with a different set of capabilities → agent.

### Subagents vs agent teams

Every agent in this repo is designed as a **subagent** — a focused specialist that does work and reports back. Claude Code also offers **agent teams** (experimental), where multiple Claude instances coordinate through shared task lists and direct messaging. These are different tools for different problems.

**Why these agents are subagents:**
- Each agent has a single, well-defined role (review code, audit security, write tests)
- They report findings or deliver artifacts back to the caller — they don't need to discuss with each other
- Token cost is proportional to the task, not multiplied per teammate
- Tool restrictions, hooks, and model selection give enough control without team coordination overhead

**When agent teams would add value:**
- Multiple reviewers need to cross-reference and challenge each other's findings (e.g., a security reviewer flagging that an a11y fix introduces an XSS vector)
- Debugging with competing hypotheses — agents actively trying to disprove each other's theories
- Cross-layer feature work where frontend, backend, and test writers need to agree on interfaces in real time

**Current tradeoffs against teams:**
- Significantly higher token usage (each teammate is a full Claude instance)
- Experimental status with known limitations (no session resumption, task status lag, slow shutdown)
- No per-agent effort control, so teammates can't run at different reasoning depths

For now, subagents cover our use cases more efficiently. Revisit teams when token costs improve or per-agent effort levels land.

### Agent-scoped hooks

Agents can define lifecycle hooks in their frontmatter. These hooks run only when the agent is active, enforcing constraints structurally rather than relying on prompt instructions alone.

Two patterns demonstrated in this repo:

**Command blocking** (`code-reviewer.md`) - A PreToolUse hook on `Bash` that regex-matches destructive commands (`rm`, `mv`, `git commit`, etc.) and exits with code 2 to block execution. A second matcher blocks `Write|Edit` entirely. This makes the "read-only" contract enforceable, not just advisory. The logic lives in external scripts (`hooks/agent-guard-readonly.sh` and `hooks/agent-guard-write-block.sh`) to avoid fragile inline YAML.

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "~/.claude/hooks/agent-guard-readonly.sh"
          timeout: 5
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "~/.claude/hooks/agent-guard-write-block.sh"
          timeout: 5
```

**Content validation** (`quick-edit.md`) - A PreToolUse hook on `Write|Edit` that counts lines in the tool input and blocks edits exceeding 50 lines. Enforces the "max 50 lines" escalation rule at the tool level. Logic in `hooks/agent-guard-max-lines.sh`.

```yaml
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "~/.claude/hooks/agent-guard-max-lines.sh"
          timeout: 5
```

Hook syntax: `matcher` is a regex against tool names. `exit 2` blocks the tool call. `exit 0` allows it. `timeout` is in seconds. Prefer external scripts over inline `command: |` blocks — inline YAML is fragile and a parse error silently breaks enforcement.

### Preloading skills

The `skills` field loads skill content into the agent's context at startup. Unlike invoking a skill mid-conversation, preloading injects the full skill instructions before the agent begins work.

```yaml
skills:
  - debug-wp
```

This is used on `wp.md` to preload the `debug-wp` debugging methodology. The tradeoff is context cost - every preloaded skill consumes tokens on every invocation, even when not needed. Only preload skills that are central to the agent's role.

### Allowlist vs denylist tooling

Two approaches to restricting an agent's tools:

**Allowlist** (`tools`) - Explicitly lists every tool the agent can use. Agent can use ONLY these tools. Best when the agent has a narrow, well-defined role.

```yaml
tools: Read, Grep, Glob  # Only these three - nothing else
```

**Denylist** (`disallowedTools`) - Agent inherits all tools from the parent session, minus the listed ones. Best when the agent needs most tools but should be blocked from specific capabilities.

```yaml
disallowedTools: WebSearch, WebFetch  # Everything except these two
```

Used on `test-writer.md` - test writers should work with the codebase (Read, Write, Edit, Bash, Grep, Glob, and any future tools), but should never browse the web for test patterns. A denylist is more maintainable here than an allowlist that needs updating when new tools are added.

**When to use which:**
- Use `tools` (allowlist) for restrictive agents: code reviewers, auditors, read-only specialists
- Use `disallowedTools` (denylist) for permissive agents that need "everything except X"
- Don't use both on the same agent - pick one approach

### New in recent releases

A few agent-related features worth knowing about:

**Permission modes** - Agents can specify a `permissionMode` to control how tool permissions are handled. `plan` mode lets the agent analyze without modifying files. `dontAsk` auto-denies tools unless pre-approved. `bypassPermissions` skips all prompts (for safe environments). The same five modes (`default`, `acceptEdits`, `plan`, `dontAsk`, `bypassPermissions`) are also available as a global `defaultMode` setting.

**Agent teams** (experimental) - Multiple Claude Code instances coordinating on work. A team lead delegates, teammates work independently with shared task lists and direct messaging. Enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` or settings. Higher token usage than single sessions. See the [agent teams docs](https://code.claude.com/docs/en/agent-teams).

**PostToolUseFailure** - A hook event that fires after a tool call fails (companion to `PostToolUse` which fires on success). Cannot block since the failure already happened. Useful for logging or alerting on tool failures.

**Plugin hooks** - Plugins can bundle their own hooks via a `hooks/hooks.json` file. When a plugin is enabled, its hooks merge with user and project hooks. This is a plugin-specific mechanism, not a standalone alternative to `settings.json` for regular hook configuration.

---

### Files in this folder

How to use this folder in Claude:

1. Copy `agents/` to `~/.claude/agents/`
2. Run `/agents` to confirm discovery and invocation names
3. Keep each agent focused and frontmatter-driven (`description`, `tools`, `model`, `maxTurns`, etc.)

| File | What it does | Notable features |
|------|--------------|------------------|
| `a11y.md` | Deep WCAG 2.2 accessibility auditor (semantic HTML, keyboard, ARIA, forms, contrast). | read-only |
| `architect.md` | Deep architectural research and recommendation agent (decision docs, no implementation). | |
| `backend-builder.md` | Backend implementation specialist for routes, schemas, and server-side services. | |
| `cleanup.md` | Dead-code and cruft cleanup specialist. | |
| `code-reviewer.md` | Read-only reviewer for bugs, edge cases, and CLAUDE.md compliance. | `hooks` (command blocking) |
| `frontend-builder.md` | Frontend implementation specialist for components/pages/features. | |
| `migration-reviewer.md` | Database migration safety reviewer (SQL, ORM, WordPress dbDelta). | read-only |
| `perf.md` | Performance audit specialist (runtime, bundle, rendering inefficiencies). | |
| `quick-edit.md` | Fast trivial-edit specialist with strict scope guardrails. | `hooks` (content validation) |
| `security.md` | Deep security audit specialist adapted to stack context. | |
| `simplify.md` | Complexity-reduction specialist for over-engineered code. | |
| `test-writer.md` | Test-writing specialist aligned with project test framework/patterns. | `disallowedTools` |
| `ui-review.md` | UI/UX review specialist for usability/accessibility/responsiveness. | |
| `wp.md` | Principal WordPress implementation specialist (architecture/hooks/REST/editor). | |
| `wp-perf.md` | WordPress performance specialist (queries, caching, CWV, DB optimization). | |
| `wp-reviewer.md` | Read-only WordPress code reviewer (PHP/hooks/queries/REST/security standards). | read-only, lean context |
| `wp-security.md` | WordPress security specialist (sanitization, escaping, nonce/auth/REST risk). | `model: opus` |

`references/` contains supporting reference docs used by WordPress-specialized agents.

`README.md` in this folder is the usage guide and frontmatter reference.

---

## Continue Reading

- Runtime setup and loading model: [Core Guide](../docs/core-guide.md)
- Hook enforcement and lifecycle events: [Hooks README](../hooks/README.md)
- Skills and memory model: [Skills README](../skills/README.md)



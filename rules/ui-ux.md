---
paths: "**/*.vue,**/*.jsx,**/*.tsx,**/*.svelte,**/*.css,**/*.scss,**/*.html,**/components/**,**/views/**,**/pages/**,**/template-parts/**,**/templates/**,**/theme/**,**/themes/**,**/blocks/**,**/patterns/**"
---
<!-- Last updated: 2026-03-23T16:30+11:00 -->

# UI/UX & Accessibility

## Opinionated Design
> Defaults. Project design system overrides these.

- Avoid "AI-Generic" layouts. Use varied spacing, subtle borders (not just shadows), and meaningful typography hierarchy.
- **8pt Grid:** All padding, margins, and layout offsets must be multiples of 8px (or 4px for tight spots).
- **Micro-interactions:** Add subtle hover/active states and transitions. Use what's already installed (framer-motion, motion, GSAP, etc.) or fall back to CSS transitions.

## Accessibility (A11Y)
- Use semantic HTML (`main`, `nav`, `section`, `article`). Prefer native HTML elements over ARIA — the first rule of ARIA is "don't use ARIA" when native semantics suffice.
- All interactive elements must have accessible names — prefer visible labels and semantic HTML over `aria-label`. Only use `aria-label` when no visible text exists.
- Check color contrast (AA standard minimum).
- 100% keyboard navigability - focus states must be visible.

## Anti-AI Polish
- Use "Empty States" and "Loading Skeletons" instead of blank screens.
- Implement toast notifications or inline feedback for user actions.
- Avoid pure `#000` or `#FFF`. Use "Rich Grays" (e.g., slate-900).

## Visual / CSS Bugs
- **You cannot see rendered output.** Do not trace rendering pipelines in your head — you will always be guessing.
- **One-round proposal.** For visual bugs: (1) identify the most likely CSS/DOM cause from the code, (2) propose the fix with your reasoning, (3) ask the user to verify. If wrong, ask what they see — don't theorize further.
- **Screenshots are your only ground truth.** Study what the screenshot shows before reading code. The visual symptom narrows the search space more than tracing call chains.
- **Prefer CSS-level fixes over widget/DOM workarounds.** CSS properties (border, padding, background) apply uniformly across lines and states. Widget-level fixes (character rendering, inline spans) are fragile across fonts, line heights, and empty lines.

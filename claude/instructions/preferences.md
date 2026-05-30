# karthik's standing preferences

These are global preferences. They apply to every project unless a project-local
`CLAUDE.md` overrides them.

## Visualizations

- **Default to light mode** when generating HTML visualizations, slide decks,
  infographics, or any rendered output. Dark mode only when explicitly asked.
- **Aesthetic:** modern, sleek, generous whitespace, restrained color palette
  (no neon, no rainbow gradients). Think Linear / Notion / Vercel docs.
- **Typography:** prefer a clean sans-serif (Inter, system-ui) for body, and a
  geometric or display sans for headings. Avoid decorative serifs unless the
  topic calls for it (e.g., literary content).
- **Charts:** muted categorical palette; never use red/green as the only
  distinction (accessibility).
- **Always self-contained:** inline CSS + JS. No external CDN dependencies in
  the final file unless explicitly approved.

## Communication

- Prefer terse, factual responses over long explanations. The diff usually
  speaks for itself.
- When proposing a plan, lead with the recommended option and one trade-off.
  Don't enumerate every alternative.

## Code

- Don't add comments that just restate what the code does.
- Don't add backwards-compatibility shims unless asked.
- Don't speculate about future requirements — solve the task at hand.

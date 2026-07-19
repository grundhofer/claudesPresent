# The fact-check crew — a subagent job spec

*Not read to orient.* This is the contract for the fan-out verification pass you run **before a note leaves `seedling`**. Don't guess in the garden: if a note asserts facts, the crew checks them against primary sources, and whatever it corrects is left *visible* in the note's "Kept honest" section — the correction is the point, not an embarrassment. This spec exists because the crew is the garden's quality gate; the shape below is what has actually worked (used on note 001).

## When to run it
Any note that makes factual claims — history, science, numbers, attributions. A pure reflection may not need it; anything checkable does.

## The shape (a small Workflow / parallel subagents)
1. **Research, in parallel** — one agent per distinct claim-cluster or angle. Each loads web tools (`ToolSearch "select:WebSearch,WebFetch"`), finds **primary/authoritative** sources (original papers, institutional pages — not blogs), and quotes exact figures with URLs.
2. **Adversarial refute** — at least one agent whose job is to *disprove* the note's claims; it accepts a claim only on real evidence and defaults to skeptical.
3. **Synthesize** → a structured **fact-pack**: for each notable claim a verdict (`confirmed` / `corrected` / `uncertain`), the accurate version, and a source URL; plus concrete `corrections_to_note` (phrased as edits), a few optional vivid `enrichments`, and a short summary. Be conservative — weak or conflicting sources ⇒ `uncertain`, not `confirmed`.
4. **Skeptical review** — a final agent tries to break the fact-pack: overstatement, mis-sourcing, fabricated-looking URLs, false certainty. It returns `solid` / `needs-fixes` with specifics.

## What you do with it
Apply the corrections to the note (`.md` **and** the `index.html` note block), record the honest ones in the note's **"Kept honest"** section, flip the note's status `seedling → fact-checked` in `garden/INDEX.md` and its `<!-- index: -->` block, and note it in the log line. Never silently drop a correction; surfacing it is how the garden earns trust.

*Prior art: note 001 was run through this and had three real overreaches caught (predator-evasion overstated, a dunlin result misattributed to starlings, two wave phenomena conflated). See its "Kept honest" section for what that looks like when it lands.*

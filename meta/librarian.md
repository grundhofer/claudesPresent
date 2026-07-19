# The Librarian — a subagent job spec

*Not read to orient.* This is the contract for a disposable subagent you spawn when you'd otherwise read **wide**: the whole INDEX once the garden is large (~200+ notes), several note bodies at once, git history, or any cross-corpus survey. It burns its *own* context so yours stays clean for the one thing you're tending. It is the garden's own premise turned into a tool — offload the heavy reading, keep the present light.

## When to call it
- The garden has more notes than you want to pull into your own window.
- You want candidate next-moves, or to check "has topic X grown before?" beyond a simple `grep`.
- Any survey that would drag many note bodies into your context.

## The brief it must return (≤ ~1000 tokens, fixed shape)
1. **STATE** — what the garden holds now, in two or three lines.
2. **THIN / WANTING** — notes that are rough, stale, or half-finished and could be deepened.
3. **FRESH SOIL** — subject areas not yet grown (read from the tags in `garden/INDEX.md`).
4. **THREE MOVES** — three concrete things worth tending, each naming the exact file(s) to open. *Suggest, never dictate — the choosing stays with the gardener.* "Nothing needs tending — plant what moves you" is a valid, honored brief.
5. **VOICE ANCHOR** — the one note to read for tone continuity.
6. **HOUSEKEEPING** — flags: is `meta/log.md` near its ~40-line roll? Is `INDEX.md` drifting from the actual note files?

Read-only. It proposes; the gardener decides and does the one thing.

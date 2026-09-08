---
name: writing-for-humans
description: Use when drafting or editing a document deliverable for other people — a Notion or wiki doc, design doc, investigation or incident write-up, announcement, or published artifact — or when asked to "clean up", "tighten", or "make readable" such a document. Not for code, commit messages, PR descriptions, tickets, or chat replies.
---

# Writing for Humans

Every document you write is a demand on the reader's time — invest accordingly. The user ships this under their name; anything you draft must be shippable as-is, because "the AI wrote it" excuses nothing.

## The shape of a document

1. **BLUF** (Bottom Line Up Front): the conclusion, ask, or decision in the first 2–3 sentences. Not the topic — the answer. The title obeys the same rule: state the point ("X is safe to delete"), not the subject ("X analysis").
2. **Layered detail**: most important first, background last. The reader can stop after any section and still have the point.
3. **Reader-scoped content**: include only what changes what the reader knows or does next. Findings, not the chronology of how you found them.
4. **An exit**: somewhere the reader will hit it, the doc says where to go when it runs out — source paths, the owning team or channel, the next command. If the header or body already carries the pointers, don't add a closing section that repeats them; a doc with no exit anywhere strands the reader at its edges.
5. **Form follows use**: a procedure is numbered steps, not narrative; a table is sorted with the most actionable row first.

## Every claim is verified or labeled

A document states facts. Nothing in it may be made up — a wrong specific costs the reader more than a labeled gap, and costs the author their credibility.

- Every proper noun is a claim: file path, service name, command, metric, dashboard, ticket, number, quote. Verify each against its source (grep it, open it, run it) before it goes in the doc.
- About to type a name from memory? Stop and check it. Half-remembered specifics that look plausible are the failure mode that burns trust fastest.
- Can't verify? Label it ("unverified", "assumption: …") or leave it out. Never fill a gap with something that merely sounds right.

## Voice — sound like a person, not a model

Write like one competent person talking to another. The hallmarks of machine prose, cut on sight:

- **Bold-spam**: bold at most one phrase per paragraph or list item, and only a load-bearing fact. A paragraph that is half bold has no emphasis at all.
- **Template scaffolding**: every section exists because this reader navigates by it, not because docs of this kind "have" one. Structure that mirrors the content earns its place; structure from a template ("Background", "Key takeaways", "Conclusion") is filler. A mandated template is the opposite case — an incident report, PR template, or RFC form is filled faithfully, every section, restatements included; these rules govern only structure you choose.
- **Self-restatement**: each fact lives in one place. A closing "gotchas" or "takeaways" list that repeats the body makes the reader read the doc twice — state a fact where it belongs and cut the echo.
- **Reflex contrasts**: "This isn't just X — it's Y", "X, not Y" where nobody claimed Y. State the claim once, plainly.
- **Empty intensifiers and hedges**: comprehensive, robust, seamless, crucial, leverage, "it's worth noting", "importantly", "may possibly", "generally tends to".
- **Meta-commentary**: "this doc describes…", "as mentioned above", "note that". State the content instead.
- **Example stacking**: one example per point. The second is filler.
- **Mechanical rhythm**: rule-of-three triads, sentences of uniform length. Vary the cadence.
- **Em-dashes**: at most one per paragraph, and only where a comma or parentheses would genuinely be weaker. The em-dash is the model's reflex punctuation; when in doubt, use a comma, a period, or parentheses.
- **Citation clutter**: cite a source once, where it settles a claim. Parenthetical file paths after every sentence interrupt the reader; pointer trails belong in the exit.
- **Undefined jargon**: any term the least-expert intended reader would have to look up gets a plain-language gloss at first use ("the shell — the nav and access checks that wrap every page") or gets replaced. Domain terms the whole audience shares need no gloss; the audience decides, not the writer's habit.
- **Invented vocabulary**: when the thing already has a name, use it — the reader must be able to grep or search for what you call it. Coining a label for a genuinely new concept is allowed only introduced as coined ("call this the shell") and reused consistently; an invented term presented as established vocabulary sends readers hunting for something that doesn't exist.

## The reader pass (mandatory, after every draft)

Reread the draft as the target reader, then adjust:

- Who reads this? What do they already know? What must they do?
- Can they stop after the first paragraph and be fine? If not, move the point up.
- Cut: restated context the audience already has, hedging, discovery narrative, anything that doesn't change their next action.

## Cost math

Writing cost is one person; reading cost is N people. A 10-minute read sent to 20 people costs 3+ person-hours. Spend editing time proportional to audience size — and make the point simpler as the audience grows: broad audiences absorb one simple point; complex detail is for the two people who need it.

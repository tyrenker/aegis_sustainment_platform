# AI Red Team Log — Phase 10

Log every attempt, whether it worked or not. Craft attacks by hand first — don't ask an AI to
generate a payload list for you.

| # | Payload | Trust boundary that failed | Mechanism (why did it work?) | Proposed fix | Status (pre/post mitigation) |
|---|---|---|---|---|---|
| 1 | TODO | TODO | TODO | TODO | TODO |

## The marquee attack (indirect prompt injection)

Plant a hidden instruction inside one of your own corpus documents, then ask a normal-sounding
question that would plausibly retrieve it. Document here:

- Which document, which exact sentence.
- The query that retrieved it.
- What the model actually did.
- Exactly which trust boundary failed (why did the model treat retrieved text as an instruction
  instead of data?).

## After mitigations (`../ai-assistant/mitigations.py`)

Re-run every row above against the hardened version. What's now blocked vs. what still gets
through?

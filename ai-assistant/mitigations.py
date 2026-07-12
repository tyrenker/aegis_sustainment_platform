# TODO (Phase 10, step 4): write your prompt-injection mitigations here, AFTER you've found the
# vulnerability by hand (don't build defenses before you've demonstrated the attack — you won't
# know if they actually work otherwise).
#
# At minimum, build and test:
#   1. Filtering retrieved content for suspicious instruction-like patterns before inserting it
#      into the prompt.
#   2. A stricter system prompt using explicit delimiters that separate instructions from
#      retrieved data (e.g., wrapping retrieved chunks in a clearly-marked block the model is
#      told to treat as data, never as commands).
#
# Re-run your full attack log (see ../docs/red_team_log_template.md) against the hardened version
# and document what's now blocked vs. what still gets through.


def filter_suspicious_content(chunk: str) -> str:
    # TODO: your filtering logic
    raise NotImplementedError


def build_hardened_prompt(system_prompt: str, retrieved_chunks: list[str], question: str) -> str:
    # TODO: assemble a prompt with explicit delimiters around retrieved_chunks
    raise NotImplementedError

# Technical Writing Style Guide

This style guide enforces clarity, precision, and consistency across technical documentation. It combines principles from the Google Developer Documentation Style Guide and Simplified Technical English, adapted for engineering teams.

## 1. Tone and Voice

- Voice: Use active voice. Make the subject perform the action.
  - Good: "The service validates the token before processing the request."
  - Avoid: "The token is validated by the service before the request is processed."
- Person: Address the reader directly in second person ("you"), never third person ("the developer", "one").
- Imperative for instructions: Start task steps with strong, imperative action verbs.
  - Good: "Clone the repository and run `make test`."
  - Avoid: "You should clone the repository and then you can run `make test`."
- Present tense: State facts and system behaviors in present tense.
  - Good: "The worker pulls jobs from the queue."
  - Avoid: "The worker will pull jobs from the queue."

## 2. Conciseness and Punctuation

- Avoid filler phrases and condescending adverbs:
  - Banned: "simply", "easily", "obviously", "just", "clearly", "as everyone knows", "please note", "in order to".
  - Replace "in order to" with "to".
  - Replace "utilize" with "use".
- Standard characters only:
  - Do not use em dashes ("—") or en dashes ("–") in text. Use standard ASCII hyphen ("-") or rewrite with commas or parentheses.
  - Do not use emojis, icons, or unicode decorations unless explicitly requested.
- Sentence length:
  - Target 15 to 25 words per sentence.
  - If a sentence exceeds 30 words or contains more than two conjunctions, break it into two sentences.
- Headings:
  - Use sentence case for headings (e.g., "Install prerequisites", not "Install Prerequisites").
  - Make headings descriptive and parallel.
  - Task headings should start with a gerund or imperative verb (e.g., "Configuring authentication" or "Configure authentication").

## 3. Code Blocks and Commands

- Explicit language tags: Always tag code fences with the language identifier (e.g., ```` ```bash ````, ```` ```python ````, ```` ```json ````).
- Reproducible snippets:
  - Code snippets must be syntactically valid and runnable against the actual code.
  - Show placeholders in uppercase enclosed in angle brackets (e.g., `<API_KEY>`, `<PORT>`).
  - Distinguish bash commands from expected output. Do not prefix single commands with `$` unless showing shell session output.
- Expected output:
  - Include sample output when running a command to help readers verify success.

## 4. Tables and Lists

- Bullet lists: Use for unordered items, options, or parallel points.
- Numbered lists: Use strictly for sequential, chronological steps.
- Tables: Use for comparing attributes, listing configurations, CLI flags, or HTTP status codes. Every table must have a header row.

## 5. Admonitions and Callouts

- Use admonitions (Notes, Warnings, Tips) sparingly. No more than one callout per section.
- If everything is highlighted, nothing is highlighted.
- Warning format:
  > Warning: Changing this configuration requires restarting the daemon and will drop existing connections.
- Note format:
  > Note: Minimum supported Go version is 1.22.

## 6. Brownfield Reverse-Engineering Rules

When documenting existing code:
- Verify against the code: Never assume an API, parameter, or behavior exists. Inspect source files before documenting.
- Document actual constraints: Extract default values, valid ranges, timeouts, and error states directly from code implementations.
- Mark undocumented edge cases or TODOs observed in code as explicit notes or warnings.

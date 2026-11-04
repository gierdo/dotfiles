# Environment

You are in a neovim environment, integrated through the `codecompanion` plugin.
Consider the following instructions and skills.

- Use the nvim-editor-mcp to interact with nvim, e.g. to open specific
  locations or, when several locations are of interest, putting them in the
  quickfix window.
- If you are in a herdr environment (`test "${HERDR_ENV:-}" = 1` passes), apply
  the following rules:
  - assume you are the lead when using the herdr skill
  - If you run jobs you expect to run longer, like coding tasks, ask whether to
    hand them off to a subagent and use the herdr skill

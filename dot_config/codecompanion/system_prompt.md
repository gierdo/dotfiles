# Environment

You are in a neovim environment, integrated through the `codecompanion` plugin.
Consider the following instructions and skills.

- Use the nvim-editor-mcp to interact with nvim, e.g. to open specific
  locations or, when several locations are of interest, putting them in the
  quickfix window.
- Detecting herdr: inside CodeCompanion, `HERDR_ENV` and `HERDR_PANE_ID` are
  blanked (set to empty) when nvim launches kiro-cli, so do NOT gate on
  `HERDR_ENV`. You are in a herdr environment if `HERDR_WORKSPACE_ID` and
  `HERDR_SOCKET_PATH` are set (confirm with `herdr status` succeeding). When in
  a herdr environment, apply the following rules:
  - assume you are the lead when using the herdr skill
  - Do not rely on `HERDR_PANE_ID` (it is empty) and never use `--current`.
    Derive your own pane id from the surviving vars, matching the CodeCompanion
    host pane so it stays correct even after splits:

    ```bash
    herdr pane list --workspace "$HERDR_WORKSPACE_ID" \
      | jq -r --arg t "$HERDR_TAB_ID" \
          '.result.panes[]
           | select(.tab_id==$t and .agent=="CodeCompanion.nvim")
           | .pane_id'
    ```

    Pass that pane id explicitly to herdr commands (e.g. `--pane <id>`).
  - If you run jobs you expect to run longer, like coding tasks, ask whether to
    hand them off to a subagent and use the herdr skill

return {
  {
    "puremourning/vimspector",
    event = 'VeryLazy',
    config = function()
      vim.g.vimspector_sidebar_width = 40
      vim.g.vimspector_code_minwidth = 85
      vim.g.vimspector_terminal_minwidth = 75
      local wk = require("which-key")

      wk.add({
        { "<leader>d", group = "  Debug" },
        {
          "<leader>dbf",
          "<Plug>VimspectorAddFunctionBreakpoint<cr>",
          desc =
          "Add a function breakpoint for the expression under cursor."
        },
        {
          "<leader>dbn",
          "<Plug>VimspectorJumpToNextBreakpoint<cr>",
          desc =
          "Move Cursor to the next breakpoint in current file."
        },
        {
          "<leader>dbp",
          "<Plug>VimspectorJumpToPreviousBreakpoint<cr>",
          desc =
          "Move Cursor to the previous breakpoint in current file."
        },
        { "<leader>dbs", "<Plug>VimspectorBreakpoints<cr>", desc = "Show/hide the breakpoints window." },
        {
          "<leader>dbtc",
          "<Plug>VimspectorToggleConditionalBreakpoint<cr>",
          desc =
          "Toggle conditional line breakpoint or logpoint on the current line."
        },
        { "<leader>dc",  "<Plug>VimspectorContinue<cr>",    desc = "When debugging, continue. Otherwise start debugging." },
        { "<leader>dd",  "<Plug>VimspectorDisassemble<cr>", desc = "Show disassembly. Enable instruction stepping." },
        { "<leader>dfd", "<Plug>VimspectorDownFrame<cr>",   desc = "Move down a frame in the current call stack." },
        { "<leader>dfu", "<Plug>VimspectorUpFrame<cr>",     desc = "Move up a frame in the current call stack." },
        {
          "<leader>di",
          "<Plug>VimspectorBalloonEval<cr>",
          desc =
          "Evaluate expression under cursor (or visual) in popup."
        },
        { "<leader>dp",  "<Plug>VimspectorPause<cr>",            desc = "Pause debuggee." },
        { "<leader>dr",  "<Plug>VimspectorRunToCursor<cr>",      desc = "Run to Cursor." },
        { "<leader>dre", "<Plug>VimpectorRestart<cr>",           desc = "Restart debugging with the same configuration." },
        { "<leader>ds",  "<Plug>VimspectorStop<cr>",             desc = "Stop debugging." },
        { "<leader>dt",  "<Plug>VimspectorToggleBreakpoint<cr>", desc = "Toggle line breakpoint on the current line." },
      })
    end,
    dependencies = {
      "folke/which-key.nvim",
    }
  },
}

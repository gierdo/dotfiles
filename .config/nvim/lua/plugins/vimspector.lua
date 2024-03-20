return {
  {
    "puremourning/vimspector",
    event = 'VeryLazy',
    config = function()
      vim.g.vimspector_sidebar_width = 40
      vim.g.vimspector_code_minwidth = 85
      vim.g.vimspector_terminal_minwidth = 75
      local wk = require("which-key")

      wk.register {
        ["<leader>d"] = {
          name = "  Debug",
          c = { "<Plug>VimspectorContinue<cr>", "When debugging, continue. Otherwise start debugging." },
          s = { "<Plug>VimspectorStop<cr>", "Stop debugging." },
          re = { "<Plug>VimpectorRestart<cr>", "Restart debugging with the same configuration." },
          p = { "<Plug>VimspectorPause<cr>", "Pause debuggee." },
          t = { "<Plug>VimspectorToggleBreakpoint<cr>", "Toggle line breakpoint on the current line." },
          bs = { "<Plug>VimspectorBreakpoints<cr>", "Show/hide the breakpoints window." },
          bn = { "<Plug>VimspectorJumpToNextBreakpoint<cr>", "Move Cursor to the next breakpoint in current file." },
          bp = { "<Plug>VimspectorJumpToPreviousBreakpoint<cr>", "Move Cursor to the previous breakpoint in current file." },
          btc = { "<Plug>VimspectorToggleConditionalBreakpoint<cr>", "Toggle conditional line breakpoint or logpoint on the current line." },
          bf = { "<Plug>VimspectorAddFunctionBreakpoint<cr>", "Add a function breakpoint for the expression under cursor." },
          r = { "<Plug>VimspectorRunToCursor<cr>", "Run to Cursor." },
          d = { "<Plug>VimspectorDisassemble<cr>", "Show disassembly. Enable instruction stepping." },
          fu = { "<Plug>VimspectorUpFrame<cr>", "Move up a frame in the current call stack." },
          fd = { "<Plug>VimspectorDownFrame<cr>", "Move down a frame in the current call stack." },
          i = { "<Plug>VimspectorBalloonEval<cr>", "Evaluate expression under cursor (or visual) in popup." },
          -- { "<Plug>VimspectorGoToCurrentLine<cr>",             "Reset the current program counter to the current line." },
          -- { "<Plug>VimspectorStepOver<cr>",                    "Step Over." },
          -- { "<Plug>VimspectorStepInto<cr>",                    "Step Into." },
          -- { "<Plug>VimspectorStepOut<cr>",                     "Step out of current function scope." },
          -- { "<Plug>VimspectorJumpToProgramCounter<cr>",        "Move Cursor to the program counter in the current frame." },
        },
      }
    end,
    dependencies = {
      "folke/which-key.nvim",
    }
  },
}

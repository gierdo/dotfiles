return {
  {
    "jake-stewart/multicursor.nvim",
    config = function()
      local mc = require("multicursor-nvim")

      mc.setup()

      -- Add cursors above/below the main cursor.
      vim.keymap.set({ "n", "v" }, "<c-up>", function()
        mc.addCursor("k")
      end, { desc = "New cursor above" })
      vim.keymap.set({ "n", "v" }, "<c-down>", function()
        mc.addCursor("j")
      end, { desc = "New cursor below" })

      -- Jump to the next word under cursor but do not add a cursor.
      vim.keymap.set({ "n", "v" }, "<c-s>", function()
        mc.skipCursor("*")
      end)

      -- Rotate the main cursor.
      vim.keymap.set({ "n", "v" }, "<c-left>", mc.nextCursor, { desc = "Select next cursor" })
      vim.keymap.set({ "n", "v" }, "<c-right>", mc.prevCursor, { desc = "Select previous cursor" })

      -- Add and remove cursors with control + left click.
      vim.keymap.set("n", "<c-leftmouse>", mc.handleMouse)

      vim.keymap.set({ "n", "v" }, "<c-q>", function()
        if mc.cursorsEnabled() then
          -- Stop other cursors from moving.
          -- This allows you to reposition the main cursor.
          mc.disableCursors()
        else
          mc.addCursor()
        end
      end)

      vim.keymap.set("n", "<esc>", function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        elseif mc.hasCursors() then
          mc.clearCursors()
        else
          -- Default <esc> handler.
        end
      end)

      -- Align cursor columns.
      vim.keymap.set("n", "<C-A-a>", mc.alignCursors, { desc = "Align cursors" })

      -- Append/insert for each line of visual selections.
      vim.keymap.set("v", "I", mc.insertVisual)
      vim.keymap.set("v", "A", mc.appendVisual)

      -- match new cursors within visual selections by regex.
      vim.keymap.set("v", "M", mc.matchCursors)

      -- Customize how cursors look.
      vim.api.nvim_set_hl(0, "MultiCursorCursor", { link = "Cursor" })
      vim.api.nvim_set_hl(0, "MultiCursorVisual", { link = "Visual" })
      vim.api.nvim_set_hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
      vim.api.nvim_set_hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
    end,
  },
}

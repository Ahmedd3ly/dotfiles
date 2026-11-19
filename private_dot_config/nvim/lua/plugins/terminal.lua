-- Let the shell keep Ctrl+H/J/K/L (backspace, newline, kill-line, clear)
-- instead of LazyVim's window-navigation mappings in terminal mode.
return {
  {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        win = {
          keys = { nav_h = false, nav_j = false, nav_k = false, nav_l = false },
        },
      },
    },
  },
}

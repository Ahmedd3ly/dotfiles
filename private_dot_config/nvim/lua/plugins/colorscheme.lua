-- Tokyo Night over a translucent kitty + Hyprland blur (the HyDE look).
-- Why: the style follows the desktop theme (theme-pick, SUPER+Shift+T):
-- palette.json "nvim_style" = moon for Mocha (LazyVim's default, unchanged),
-- day for Latte. Read once at startup through theme-get; Neovim's own
-- terminal-background detection answers too late (after the colorscheme has
-- loaded), which left moon's pale text on Latte's light kitty background.
-- Already-open Neovim instances keep their style until restarted.
local function desktop_style()
  local ok, out = pcall(vim.fn.system, { "theme-get", "nvim_style" })
  out = ok and vim.v.shell_error == 0 and vim.trim(out) or ""
  return (out == "day" or out == "moon" or out == "night" or out == "storm") and out or "moon"
end

local style = desktop_style()
vim.o.background = style == "day" and "light" or "dark"

return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = style,
      transparent = true,
      styles = { sidebars = "transparent", floats = "transparent" },
    },
  },
}

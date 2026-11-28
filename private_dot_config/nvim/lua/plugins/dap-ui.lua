-- Debugger UI trimmed to two panes: variables + call stack on the left,
-- program output below. Watches/REPL stay reachable on demand.
return {
  {
    "rcarriga/nvim-dap-ui",
    opts = {
      layouts = {
        {
          position = "left",
          size = 45,
          elements = { { id = "scopes", size = 0.65 }, { id = "stacks", size = 0.35 } },
        },
        { position = "bottom", size = 10, elements = { "console" } },
      },
    },
  },
}

-- Keep in-editor markdown rendering; turn off the browser preview and LaTeX (no tools installed for it).
return {
  { "iamcco/markdown-preview.nvim", enabled = false },
  { "MeanderingProgrammer/render-markdown.nvim", opts = { latex = { enabled = false } } },
}

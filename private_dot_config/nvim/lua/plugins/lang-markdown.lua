-- Keep in-editor markdown rendering; the browser preview isn't needed.
return {
  { "iamcco/markdown-preview.nvim", enabled = false },
  { "MeanderingProgrammer/render-markdown.nvim", opts = { latex = { enabled = false } } },
}

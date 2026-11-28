-- C#/.NET via easy-dotnet: Roslyn LSP, bundled netcoredbg, test runner, user-secrets.
-- Loads only for C# buffers or :Dotnet, so nothing .NET runs while editing other files.
return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    ft = { "cs" },
    cmd = "Dotnet",
    dependencies = { "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap", "folke/snacks.nvim" },
    opts = {
      lsp = {
        enabled = true,
        preload_roslyn = false,
        roslynator_enabled = true,
        razor = { enabled = false }, -- Web APIs only; avoids needing an npm HTML server
      },
      auto_bootstrap_namespace = { type = "file_scoped", enabled = true },
    },
    keys = {
      { "<leader>Nb", "<cmd>Dotnet build<cr>", desc = "Dotnet build" },
      { "<leader>Nr", "<cmd>Dotnet run<cr>", desc = "Dotnet run" },
      { "<leader>Nt", "<cmd>Dotnet testrunner<cr>", desc = "Dotnet test runner" },
    },
  },
  -- netcoredbg comes bundled with easy-dotnet; only the formatter comes from Mason.
  { "mason-org/mason.nvim", opts = { ensure_installed = { "csharpier" } } },
  { "stevearc/conform.nvim", opts = { formatters_by_ft = { cs = { "csharpier" } } } },
  { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = { "c_sharp" } } },
}

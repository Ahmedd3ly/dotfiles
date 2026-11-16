-- Compose files must get the compound filetype or docker_compose_language_service never attaches.
return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.filetype.add({
        filename = {
          ["compose.yaml"] = "yaml.docker-compose",
          ["compose.yml"] = "yaml.docker-compose",
          ["docker-compose.yaml"] = "yaml.docker-compose",
          ["docker-compose.yml"] = "yaml.docker-compose",
        },
      })
      vim.treesitter.language.register("yaml", "yaml.docker-compose")
    end,
  },
}

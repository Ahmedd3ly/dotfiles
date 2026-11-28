-- Explorer: no diagnostic markers (odoo-ls reports across whole addon trees)
return { { "folke/snacks.nvim", opts = { picker = { sources = { explorer = { diagnostics = false } } } } } }

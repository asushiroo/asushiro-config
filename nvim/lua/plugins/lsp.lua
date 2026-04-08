return {
    {
        "mason-org/mason.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "mason-org/mason-lspconfig.nvim",
        },
        cmd = "Mason",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        },
        config = function(_, opts)
            require("mason").setup(opts)
            require("mason-lspconfig").setup({
                automatic_enable = false,
            })
            require("lsp").setup()
        end,
    },
}

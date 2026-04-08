return {
    {
        "nvim-flutter/flutter-tools.nvim",
        ft = "dart",
        cond = function()
            return vim.fn.executable("flutter") == 1
        end,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "stevearc/dressing.nvim",
        },
        main = "flutter-tools",
        opts = function()
            return {
                ui = {
                    border = "rounded",
                },
                decorations = {
                    statusline = {
                        app_version = true,
                        device = true,
                    },
                },
                lsp = {
                    capabilities = require("lsp").base_capabilities(),
                    on_attach = require("lsp").on_attach,
                },
            }
        end,
    },
    {
        "mrcjkb/rustaceanvim",
        ft = "rust",
        cond = function()
            return vim.fn.executable("rustc") == 1
        end,
        init = function()
            vim.g.rustaceanvim = {
                server = {
                    capabilities = require("lsp").base_capabilities(),
                    on_attach = require("lsp").on_attach,
                },
            }
        end,
    },
    {
        "chomosuke/typst-preview.nvim",
        ft = "typst",
        cond = function()
            return vim.fn.executable("typst") == 1
        end,
        build = function()
            require("typst-preview").update()
        end,
        opts = {},
        keys = {
            { "<A-b>", "<Cmd>TypstPreviewToggle<CR>", desc = "Typst preview toggle", ft = "typst", silent = true },
        },
    },
}

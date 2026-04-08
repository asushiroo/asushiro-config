return {
    {
        "nvimtools/none-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvimtools/none-ls-extras.nvim",
        },
        opts = {
            debug = false,
        },
        config = function(_, opts)
            local null_ls = require("null-ls")
            local builtins = require("null-ls.builtins._meta.formatting")
            local servers = require("lsp.lsp")
            local sources = {}

            for _, config in pairs(servers) do
                local formatter = config.formatter
                if formatter then
                    local base = builtins[formatter] and "null-ls.builtins.formatting." or "none-ls.formatting."
                    local ok, source = pcall(require, base .. formatter)
                    if ok and source then
                        table.insert(sources, source)
                    end
                end
            end

            null_ls.setup(vim.tbl_deep_extend("force", opts, {
                sources = sources,
            }))

            vim.lsp.config("null-ls", {})
        end,
        keys = {
            {
                "<leader>lf",
                function()
                    local has_null_ls = #vim.lsp.get_clients({ bufnr = 0, name = "null-ls" }) > 0
                    vim.lsp.buf.format {
                        async = true,
                        filter = has_null_ls and function(client)
                            return client.name == "null-ls"
                        end or nil,
                    }
                end,
                mode = { "n", "v" },
                desc = "Format code",
            },
        },
    },
}

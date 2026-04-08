local servers = {
    ["bash-language-server"] = {
        enabled = true,
        formatter = "shfmt",
    },
    clangd = {
        enabled = true,
    },
    ["css-lsp"] = {
        enabled = true,
        formatter = "prettier",
        setup = {
            settings = {
                css = {
                    validate = true,
                    lint = {
                        unknownAtRules = "ignore",
                    },
                },
                less = {
                    validate = true,
                    lint = {
                        unknownAtRules = "ignore",
                    },
                },
                scss = {
                    validate = true,
                    lint = {
                        unknownAtRules = "ignore",
                    },
                },
            },
        },
    },
    ["emmet-ls"] = {
        enabled = true,
        setup = {
            filetypes = { "html", "css", "scss", "sass", "less", "javascriptreact", "typescriptreact" },
        },
    },
    gopls = {
        enabled = true,
        formatter = "gofumpt",
        setup = {
            settings = {
                gopls = {
                    analyses = {
                        unusedparams = true,
                    },
                    gofumpt = true,
                },
            },
        },
    },
    ["html-lsp"] = {
        enabled = true,
        formatter = "prettier",
    },
    ["json-lsp"] = {
        enabled = true,
        formatter = "prettier",
    },
    ["lua-language-server"] = {
        enabled = true,
        formatter = "stylua",
        setup = {
            settings = {
                Lua = {
                    runtime = {
                        version = "LuaJIT",
                        path = (function()
                            local runtime_path = vim.split(package.path, ";")
                            table.insert(runtime_path, "lua/?.lua")
                            table.insert(runtime_path, "lua/?/init.lua")
                            return runtime_path
                        end)(),
                    },
                    diagnostics = {
                        globals = { "vim" },
                    },
                    hint = {
                        enable = true,
                    },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file("", true),
                        checkThirdParty = false,
                    },
                    telemetry = {
                        enable = false,
                    },
                },
            },
        },
    },
    omnisharp = {
        enabled = function()
            return vim.fn.executable("dotnet") == 1
        end,
        formatter = "csharpier",
        setup = {
            cmd = {
                "dotnet",
                vim.fs.joinpath(vim.fn.stdpath "data", "mason/packages/omnisharp/libexec/OmniSharp.dll"),
            },
            on_attach = function(client, bufnr)
                client.server_capabilities.semanticTokensProvider = nil
            end,
        },
    },
    pyright = {
        enabled = true,
        formatter = "black",
    },
    ["rust-analyzer"] = {
        enabled = function()
            return vim.fn.executable("rustc") == 1
        end,
        managed_by_plugin = true,
    },
    tinymist = {
        enabled = function()
            return vim.fn.executable("tinymist") == 1 or vim.fn.executable("typst") == 1
        end,
        setup = {
            settings = {
                formatterMode = "typstyle",
                formatterPrintWidth = 120,
                formatterProseWrap = true,
            },
        },
    },
    ["typescript-language-server"] = {
        enabled = true,
        formatter = "prettier",
    },
}

return servers

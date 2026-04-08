return {
    "folke/tokyonight.nvim",
    opts = {
        style = "moon",
        transparent = true,
        on_highlights = function(hl, c)
            hl.LineNr = {
                fg = "#DDE3DA",   -- 淡白（带“阴影感”）
            }
            hl.LineNrAbove = { fg = "#DDE3DA" }
            hl.LineNrBelow = { fg = "#DDE3DA" }
        end,
    },
    config = function (_, opts)
        require("tokyonight").setup(opts)
        vim.cmd("colorscheme tokyonight")
    end
}

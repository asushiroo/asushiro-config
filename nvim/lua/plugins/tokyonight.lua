return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	opts = {
		style = "moon",
		transparent = true,
		styles = {
			sidebars = "transparent",
			floats = "transparent",
		},
		on_highlights = function(hl, c)
			hl.Normal = { fg = c.fg, bg = "NONE" }
			hl.NormalNC = { fg = c.fg, bg = "NONE" }
			hl.SignColumn = { bg = "NONE" }
			hl.EndOfBuffer = { bg = "NONE" }
			hl.NormalFloat = { bg = "NONE" }
			hl.FloatBorder = { bg = "NONE" }
			hl.FloatTitle = { bg = "NONE" }
			hl.WinSeparator = { bg = "NONE" }
			hl.StatusLine = { bg = "NONE" }
			hl.StatusLineNC = { bg = "NONE" }
			hl.TabLine = { bg = "NONE" }
			hl.TabLineFill = { bg = "NONE" }
			hl.TabLineSel = { bg = "NONE" }
			hl.NvimTreeNormal = { bg = "NONE" }
			hl.NvimTreeNormalNC = { bg = "NONE" }
			hl.NvimTreeEndOfBuffer = { bg = "NONE" }
			hl.NvimTreeWinSeparator = { bg = "NONE" }

			hl.LineNr = {
				fg = "#DDE3DA",
			}
			hl.LineNrAbove = { fg = "#DDE3DA" }
			hl.LineNrBelow = { fg = "#DDE3DA" }

			-- VSCode 风格：LSP/诊断只保留下划线，不要脏背景块
			hl.LspReferenceText = { bg = "NONE", underline = true, sp = c.blue }
			hl.LspReferenceRead = { bg = "NONE", underline = true, sp = c.blue }
			hl.LspReferenceWrite = { bg = "NONE", underline = true, sp = c.orange }
			hl.LspSignatureActiveParameter = { bg = "NONE", underline = true, bold = true, sp = c.yellow }
			hl.LspInlayHint = { bg = "NONE", fg = c.comment, italic = true }

			hl.DiagnosticVirtualTextError = { bg = "NONE", fg = c.error }
			hl.DiagnosticVirtualTextWarn = { bg = "NONE", fg = c.warning }
			hl.DiagnosticVirtualTextInfo = { bg = "NONE", fg = c.info }
			hl.DiagnosticVirtualTextHint = { bg = "NONE", fg = c.hint }

			hl.DiagnosticUnderlineError = { undercurl = true, sp = c.error }
			hl.DiagnosticUnderlineWarn = { undercurl = true, sp = c.warning }
			hl.DiagnosticUnderlineInfo = { undercurl = true, sp = c.info }
			hl.DiagnosticUnderlineHint = { undercurl = true, sp = c.hint }
		end,
	},
	config = function(_, opts)
		require("tokyonight").setup(opts)
		vim.cmd("colorscheme tokyonight")
		require("core.transparent").apply()
	end,
}

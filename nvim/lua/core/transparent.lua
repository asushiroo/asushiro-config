local M = {}

local base_groups = {
	"Normal",
	"NormalNC",
	"SignColumn",
	"EndOfBuffer",
	"FoldColumn",
	"NormalFloat",
	"FloatBorder",
	"FloatTitle",
	"WinSeparator",
	"StatusLine",
	"StatusLineNC",
	"TabLine",
	"TabLineFill",
	"TabLineSel",
	"NvimTreeNormal",
	"NvimTreeNormalNC",
	"NvimTreeEndOfBuffer",
	"NvimTreeWinSeparator",
}

local function set_bg_none(name)
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
	if not ok then
		return
	end

	hl.bg = "NONE"
	hl.ctermbg = "NONE"

	vim.api.nvim_set_hl(0, name, hl)
end

function M.apply()
	for _, group in ipairs(base_groups) do
		set_bg_none(group)
	end

	local ok, config = pcall(require, "bufferline.config")
	if ok and config.highlights then
		for _, hl in pairs(config.highlights) do
			if type(hl) == "table" and hl.hl_group then
				set_bg_none(hl.hl_group)
			end
		end
	end
end

function M.setup()
	local group = vim.api.nvim_create_augroup("TransparentTerminalUi", { clear = true })

	vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter", "UIEnter" }, {
		group = group,
		callback = function()
			vim.schedule(M.apply)
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "VeryLazy",
		callback = function()
			vim.schedule(M.apply)
		end,
	})
end

return M

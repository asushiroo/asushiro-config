return {
	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = function()
		return {
			options = {
				separator_style = "thin",
				themable = false,
			},
			highlights = {
				fill = { bg = "NONE" },
				background = { bg = "NONE" },
				buffer = { bg = "NONE" },
				buffer_visible = { bg = "NONE" },
				buffer_selected = { bg = "NONE", bold = true },
				separator = { bg = "NONE" },
				separator_visible = { bg = "NONE" },
				separator_selected = { bg = "NONE" },
				close_button = { bg = "NONE" },
				close_button_visible = { bg = "NONE" },
				close_button_selected = { bg = "NONE" },
				indicator_selected = { bg = "NONE" },
				indicator_visible = { bg = "NONE" },
				tab = { bg = "NONE" },
				tab_selected = { bg = "NONE" },
				tab_close = { bg = "NONE" },
				trunc_marker = { bg = "NONE" },
				offset_separator = { bg = "NONE" },
			},
		}
	end,
	config = function(_, opts)
		require("bufferline").setup(opts)
		require("core.transparent").apply()
	end,
	keys = {
		{ "<leader>bh", ":BufferLineCyclePrev<CR>", silent = true },
		{ "<leader>bl", ":BufferLineCycleNext<CR>", silent = true },
		{ "<leader>bp", ":BufferLinePick<CR>", silent = true },
		{ "<leader>bd", ":bdelete<CR>", silent = true },
	},
	lazy = false,
}

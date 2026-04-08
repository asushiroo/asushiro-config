return {
	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },

	opts = {
		options = {
			separator_style = "thin",
		},
		highlights = {
			fill = { bg = "NONE" },
			background = { bg = "NONE" },
			buffer_selected = { bg = "NONE", bold = true },
			separator = { bg = "NONE" },
			separator_selected = { bg = "NONE" },
		},
	},
	keys = {
		{ "<leader>bh", ":BufferLineCyclePrev<CR>", silent = true },
		{ "<leader>bl", ":BufferLineCycleNext<CR>", silent = true },
		{ "<leader>bp", ":BufferLinePick<CR>", silent = true },
		{ "<leader>bd", ":bdelete<CR>", silent = true },
	},
	lazy = false,
}

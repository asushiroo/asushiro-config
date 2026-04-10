return {
	"nvim-tree/nvim-tree.lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		filters = {
			git_ignored = true,
		},
		view = {
			number = true,
			relativenumber = true,
		},
		actions = {
			open_file = {
				quit_on_open = true,
			},
		},
	},
	keys = {
		{ "<leader>uf", ":NvimTreeToggle<CR>" },
	},
}

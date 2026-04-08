return {
	{
		"nvimdev/lspsaga.nvim",
		event = "LspAttach",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			finder = {
				keys = {
					toggle_or_open = "<CR>",
				},
			},
			symbol_in_winbar = {
				enable = false,
			},
			lightbulb = {
				enable = false,
			},
		},
		keys = {
			{ "<leader>lr", "<Cmd>Lspsaga rename<CR>", desc = "LSP rename", silent = true },
			{ "<leader>lc", "<Cmd>Lspsaga code_action<CR>", desc = "Code action", silent = true },
			{ "<leader>ld", "<Cmd>Lspsaga goto_definition<CR>", desc = "Goto definition", silent = true },
			{ "<leader>lD", "<Cmd>Lspsaga peek_definition<CR>", desc = "Peek definition", silent = true },
			{ "<leader>lR", "<Cmd>Lspsaga finder ref+def+imp<CR>", desc = "References/Finder", silent = true },
			{ "<leader>li", "<Cmd>Lspsaga finder imp<CR>", desc = "Implementation finder", silent = true },
			{ "<leader>lh", "<Cmd>Lspsaga hover_doc<CR>", desc = "Hover doc", silent = true },
			{ "<leader>lP", "<Cmd>Lspsaga show_line_diagnostics<CR>", desc = "Line diagnostics", silent = true },
			{ "<leader>ln", "<Cmd>Lspsaga diagnostic_jump_next<CR>", desc = "Next diagnostic", silent = true },
			{ "<leader>lp", "<Cmd>Lspsaga diagnostic_jump_prev<CR>", desc = "Prev diagnostic", silent = true },
			{ "<leader>lo", "<Cmd>Lspsaga outline<CR>", desc = "Symbols outline", silent = true },
		},
	},
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		opts = {},
		keys = {
			{
				"<leader>lt",
				"<Cmd>Trouble diagnostics toggle focus=true<CR>",
				desc = "Trouble diagnostics",
				silent = true,
			},
			{ "<leader>lT", "<Cmd>Trouble symbols toggle focus=true<CR>", desc = "Trouble symbols", silent = true },
		},
	},
}

return {
	{
		"saghen/blink.cmp",
		version = "*",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
		opts = {
			appearance = {
				nerd_font_variant = "mono",
			},
			cmdline = {
				keymap = {
					preset = "none",
					["<Tab>"] = { "show", "accept" },
					["<C-k>"] = { "select_prev", "fallback" },
					["<C-j>"] = { "select_next", "fallback" },
					["<C-e>"] = { "cancel", "fallback" },
				},
				completion = {
					menu = {
						auto_show = true,
					},
				},
				sources = function()
					local cmdtype = vim.fn.getcmdtype()
					if cmdtype == "/" or cmdtype == "?" then
						return { "buffer" }
					end

					if cmdtype == ":" or cmdtype == "@" then
						return { "cmdline", "buffer" }
					end

					return {}
				end,
			},
			completion = {
				accept = {
					auto_brackets = {
						enabled = true,
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
				},
				ghost_text = {
					enabled = true,
				},
				list = {
					selection = {
						preselect = false,
						auto_insert = true,
					},
				},
				menu = {
					draw = {
						columns = {
							{ "label", "label_description", gap = 1 },
							{ "kind_icon", "kind" },
						},
					},
				},
				trigger = {
					show_on_backspace_in_keyword = true,
				},
			},
			keymap = {
				preset = "none",
				["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "hide" },
				["<CR>"] = { "accept", "fallback" },
				["<Tab>"] = {
					function(cmp)
						if not cmp.is_menu_visible() then
							return
						end

						return cmp.select_and_accept()
					end,
					"snippet_forward",
					"fallback",
				},
				["<S-Tab>"] = { "snippet_backward", "fallback" },
				["<C-k>"] = { "select_prev", "fallback" },
				["<C-j>"] = { "select_next", "fallback" },
				["<C-u>"] = { "scroll_documentation_up", "fallback" },
				["<C-d>"] = { "scroll_documentation_down", "fallback" },
			},
			signature = {
				enabled = true,
			},
			sources = {
				default = function()
					local cmdwin_type = vim.fn.getcmdwintype()
					if cmdwin_type == "/" or cmdwin_type == "?" then
						return { "buffer" }
					end

					if cmdwin_type == ":" or cmdwin_type == "@" then
						return { "cmdline" }
					end

					return { "lsp", "path", "snippets", "buffer" }
				end,
			},
		},
	},
}

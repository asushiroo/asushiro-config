return {
	"nvim-treesitter/nvim-treesitter",
	event = "VeryLazy",
	-- 其余部分不变
	branch = "main",
	config = function()
		local nvim_treesitter = require("nvim-treesitter")
		nvim_treesitter.setup()

		local ensure_installed = {
			"lua",
			"python",
			"rust",
			"bash",
			"json",
			"markdown",
			"toml",
			"yaml",
		}
		local pattern = {}
		for _, parser in ipairs(ensure_installed) do
			-- neovim 自己的 api，找不到这个 parser 会报错
			local has_parser, _ = pcall(vim.treesitter.language.inspect, parser)

			if not has_parser then
				-- install 是 nvim-treesitter 的新 api，默认情况下无论是否安装 parser 都会执行，所以这里我们做一个判断
				nvim_treesitter.install(parser)
			else
				-- 新版本需要手动启动高亮，但没有安装相应 parser会导致报错
				for _, filetype in ipairs(vim.treesitter.language.get_filetypes(parser)) do
					if not vim.list_contains(pattern, filetype) then
						table.insert(pattern, filetype)
					end
				end
			end
		end
		vim.api.nvim_create_autocmd("FileType", {
			pattern = pattern,
			callback = function()
				vim.treesitter.start()
			end,
		})
		-- VeryLazy 晚于 FileType，所以需要手动触发一下
		vim.api.nvim_exec_autocmds("FileType", {})
	end,
}

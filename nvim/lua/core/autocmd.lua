local ime_autogroup = vim.api.nvim_create_augroup("ImeAutoGroup", { clear = true })

vim.api.nvim_create_autocmd("InsertLeave", {
	group = ime_autogroup,
	callback = function()
		vim.system({ "macism" }, { text = true }, function(out)
			-- 用一个全局变量存储之前的语言
			PREVIOUS_IM_CODE_MAC = string.gsub(out.stdout, "\n", "")
		end)
		vim.cmd(":silent :!macism com.apple.keylayout.ABC")
	end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
	group = ime_autogroup,
	callback = function()
		if PREVIOUS_IM_CODE_MAC then
			vim.cmd(":silent :!macism " .. PREVIOUS_IM_CODE_MAC)
		end
		PREVIOUS_IM_CODE_MAC = nil
	end,
})

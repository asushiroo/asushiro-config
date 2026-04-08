local M = {}

local servers = require("lsp.lsp")

local function is_enabled(config)
	if type(config.enabled) == "function" then
		return config.enabled()
	end

	return config.enabled ~= false
end

local function base_capabilities()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities.textDocument.foldingRange = {
		dynamicRegistration = false,
		lineFoldingOnly = true,
	}

	local ok, blink = pcall(require, "blink.cmp")
	if ok then
		capabilities = blink.get_lsp_capabilities(capabilities)
	end

	return capabilities
end

local function buf_map(bufnr, mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, {
		buffer = bufnr,
		silent = true,
		desc = desc,
	})
end

local function on_attach(client, bufnr)
	buf_map(bufnr, "n", "K", vim.lsp.buf.hover, "LSP hover")
	buf_map(bufnr, "n", "gd", vim.lsp.buf.definition, "LSP definition")
	buf_map(bufnr, "n", "gD", vim.lsp.buf.declaration, "LSP declaration")
	buf_map(bufnr, "n", "gr", vim.lsp.buf.references, "LSP references")
	buf_map(bufnr, "n", "gi", vim.lsp.buf.implementation, "LSP implementation")
	buf_map(bufnr, "n", "<leader>rn", vim.lsp.buf.rename, "LSP rename")
	buf_map(bufnr, { "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP code action")
	buf_map(bufnr, "n", "<leader>lf", function()
		vim.lsp.buf.format({ async = true })
	end, "LSP format")
	buf_map(bufnr, "n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
	buf_map(bufnr, "n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
	buf_map(bufnr, "n", "<leader>e", vim.diagnostic.open_float, "Line diagnostics")
	buf_map(bufnr, "n", "<leader>q", vim.diagnostic.setloclist, "Diagnostics to loclist")

	if client.server_capabilities.inlayHintProvider then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end
end

local function setup_format_on_save()
	local group = vim.api.nvim_create_augroup("UserLspFormatOnSave", { clear = true })

	vim.api.nvim_create_autocmd("BufWritePre", {
		group = group,
		callback = function(args)
			local bufnr = args.buf
			local clients = vim.lsp.get_clients({ bufnr = bufnr })

			if #clients == 0 then
				return
			end

			local has_null_ls = #vim.lsp.get_clients({ bufnr = bufnr, name = "null-ls" }) > 0

			vim.lsp.buf.format({
				bufnr = bufnr,
				async = false,
				timeout_ms = 2000,
				filter = has_null_ls and function(client)
					return client.name == "null-ls"
				end or nil,
			})
		end,
	})
end

local function setup_diagnostics()
	vim.diagnostic.config({
		update_in_insert = true,
		severity_sort = true,
		float = {
			border = "rounded",
		},
		virtual_text = {
			spacing = 2,
		},
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = " ",
				[vim.diagnostic.severity.WARN] = " ",
				[vim.diagnostic.severity.HINT] = " ",
				[vim.diagnostic.severity.INFO] = " ",
			},
		},
	})
end

local function ensure_mason_packages()
	local ok, registry = pcall(require, "mason-registry")
	if not ok then
		return
	end

	if #registry.get_all_package_names() == 0 then
		registry.refresh()
	end

	for package_name, config in pairs(servers) do
		if not is_enabled(config) then
			goto continue
		end

		local package_ok, package = pcall(registry.get_package, package_name)
		if package_ok and not package:is_installed() then
			package:install()
		end

		if config.formatter then
			local formatter_ok, formatter = pcall(registry.get_package, config.formatter)
			if formatter_ok and not formatter:is_installed() then
				formatter:install()
			end
		end

		::continue::
	end
end

local function setup_servers()
    local mappings = require("mason-lspconfig").get_mappings().package_to_lspconfig
    local capabilities = base_capabilities()

	for package_name, config in pairs(servers) do
		if not is_enabled(config) or config.managed_by_plugin then
			goto continue
		end

		local server_name = mappings[package_name] or package_name
		local server_opts = vim.tbl_deep_extend("force", {}, config.setup or {}, {
			capabilities = capabilities,
			on_attach = function(client, bufnr)
				on_attach(client, bufnr)

				if type(config.setup) == "table" and type(config.setup.on_attach) == "function" then
					config.setup.on_attach(client, bufnr)
				end
			end,
		})

		vim.lsp.config(server_name, server_opts)

		::continue::
	end
end

local function enable_matching_server()
	local filetype = vim.bo.filetype
	local to_enable = {}

	local mappings = require("mason-lspconfig").get_mappings().package_to_lspconfig
	for package_name, config in pairs(servers) do
		if not is_enabled(config) or config.managed_by_plugin then
			goto continue
		end

		local name = mappings[package_name] or package_name
		local filetypes = vim.lsp.config[name] and vim.lsp.config[name].filetypes
		if filetypes and vim.tbl_contains(filetypes, filetype) then
			table.insert(to_enable, name)
		end

		::continue::
	end

	if #to_enable > 0 then
		vim.lsp.enable(to_enable)
	end
end

function M.setup()
	setup_diagnostics()
	setup_servers()
	ensure_mason_packages()
	setup_format_on_save()

	local augroup = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })

	vim.api.nvim_create_autocmd("FileType", {
		group = augroup,
		callback = enable_matching_server,
	})

	enable_matching_server()
end

M.base_capabilities = base_capabilities
M.on_attach = on_attach
M.is_enabled = is_enabled

return M

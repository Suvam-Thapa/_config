return {
	{
		"nvimtools/none-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"jay-babu/mason-null-ls.nvim",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local null_ls = require("null-ls")
			-- local h = require("null-ls.helpers")
			local formatting = null_ls.builtins.formatting
			local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
			-- local dart_format = h.make_builtin({
			-- 	name = "dart_format",
			-- 	method = null_ls.methods.FORMATTING,
			-- 	filetypes = { "dart" },
			-- 	generator_opts = {
			-- 		command = "dart",
			-- 		args = { "format" },
			-- 		to_stdin = true,
			-- 	},
			-- 	factory = h.formatter_factory,
			-- })
			require("mason-null-ls").setup({
				ensure_installed = {
					"black",
					"stylua",
					"prettier",
					"biome",
				},
				automatic_installation = true,
			})
			null_ls.setup({
				sources = {
					formatting.biome.with({
						filetypes = {
							"javascript",
							"javascriptreact",
							"typescript",
							"typescriptreact",
							"css",
							"html",
						},
					}),
					-- JSON
					formatting.prettier.with({
						filetypes = { "json" },
						extra_args = {
							"--tab-width",
							"4",
							"--use-tabs",
							"false",
						},
					}),
					-- Lua
					formatting.stylua,
					-- Python
					formatting.black,
					-- Dart
					-- dart_format,
				},
				-- Format on save
				on_attach = function(client, bufnr)
					if client.supports_method("textDocument/formatting") then
						vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = augroup,
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.format({
									bufnr = bufnr,
									filter = function(c)
										return c.name == "null-ls"
									end,
								})
							end,
						})
					end
				end,
			})

			-- Manual formatting keymap
			vim.keymap.set({ "n", "v" }, "<leader>f", function()
				vim.lsp.buf.format({
					bufnr = vim.api.nvim_get_current_buf(),
					filter = function(c)
						return c.name == "null-ls"
					end,
				})
			end, { desc = "Format whole file or range (in visual mode)" })
		end,
	},
}

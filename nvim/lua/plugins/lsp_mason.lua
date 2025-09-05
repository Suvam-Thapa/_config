return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
		"hrsh7th/cmp-nvim-lsp",
	},
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("mason").setup({
			ui = {
				check_outdated_packages_on_open = false,
				icons = {
					package_installed = "",
					package_pending = "",
					package_uninstalled = "",
				},
			},
		})

		local lspconfig = require("lspconfig")
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		local signs = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = " ",
			[vim.diagnostic.severity.INFO] = " ",
		}

		vim.diagnostic.config({
			signs = {
				text = signs,
			},
			virtual_text = {
				prefix = "",
			},
			underline = true,
			update_in_insert = false,
			severity_sort = true,
		})

		-- Common on_attach function
		local on_attach = function(client, bufnr)
			-- Disable LSP formatting
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false

			-- LSP Keybindings
			local opts = { buffer = bufnr, silent = true }
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
			vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
			vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
			-- vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float, opts)

			-- Show LSP status
			vim.api.nvim_buf_set_var(bufnr, "lsp_attached", true)
		end

		-- Lua Language Server
		vim.lsp.config("lua_ls", {
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
					},
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
						checkThirdParty = false,
					},
					telemetry = {
						enable = false,
					},
				},
			},
		})

		-- Python
		vim.lsp.config("pyright", {
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				python = {
					analysis = {
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
						diagnosticMode = "openFilesOnly",
						typeCheckingMode = "basic",
					},
				},
			},
		})

		-- TypeScript/JavaScript
		vim.lsp.config("ts_ls", {
			capabilities = capabilities,
			on_attach = on_attach,
			init_options = {
				preferences = {
					disableSuggestions = true,
				},
			},
			settings = {
				typescript = {
					inlayHints = {
						includeInlayParameterNameHints = "literal",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = false,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
				javascript = {
					inlayHints = {
						includeInlayParameterNameHints = "literal",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = false,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
			},
		})

		-- Tailwind CSS (unmigrated, so use lspconfig.setup)
		lspconfig.tailwindcss.setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				tailwindCSS = {
					classAttributes = { "class", "className", "ngClass", "class:list", "classList" },
					lint = {
						cssConflict = "warning",
						invalidApply = "error",
						invalidConfigPath = "error",
						invalidScreen = "error",
						invalidTailwindDirective = "error",
						invalidVariant = "error",
						recommendedVariantOrder = "warning",
					},
					validate = true,
				},
			},
		})

		-- HTML
		vim.lsp.config("html", {
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "html" },
			init_options = {
				configurationSection = { "html", "css", "javascript" },
				embeddedLanguages = {
					css = true,
					javascript = true,
				},
				provideFormatter = false, -- Use prettier instead
			},
			settings = {
				html = {
					format = {
						enable = false,
					},
					validate = {
						scripts = true,
						styles = true,
					},
				},
			},
		})

		-- CSS
		vim.lsp.config("cssls", {
			capabilities = capabilities,
			on_attach = on_attach,
			init_options = {
				provideFormatter = false,
			},
			settings = {
				css = {
					validate = true,
					format = { enable = false },
					lint = {
						unknownAtRules = "ignore",
					},
				},
				scss = {
					validate = true,
					format = { enable = false },
					lint = {
						unknownAtRules = "ignore",
					},
				},
				less = {
					validate = true,
					format = { enable = false },
					lint = {
						unknownAtRules = "ignore",
					},
				},
			},
		})

		-- Emmet
		vim.lsp.config("emmet_language_server", {
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = {
				"css",
				"html",
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"astro",
				"vue",
				"svelte",
			},
			init_options = {
				showAbbreviationSuggestions = true,
				showExpandedAbbreviation = "always",
				showSuggestionsAsSnippets = false,
			},
		})

		-- lspconfig.dartls.setup({
		-- 	capabilities = capabilities,
		-- 	on_attach = on_attach,
		-- 	filetypes = { "dart" },
		-- 	cmd = { "dart", "language-server", "--client-id", "neovim", "--client-version", "1" },
		-- 	root_dir = lspconfig.util.root_pattern("pubspec.yaml"),
		-- 	init_options = {
		-- 		closingLabels = true,
		-- 		flutterOutline = true,
		-- 		onlyAnalyzeProjectsWithOpenFiles = true,
		-- 		outline = true,
		-- 		suggestFromUnimportedLibraries = true,
		-- 	},
		-- 	settings = {
		-- 		dart = {
		-- 			completeFunctionCalls = true,
		-- 			showTodos = true,
		-- 			analysisExcludedFolders = { ".dart_tool", "build" },
		-- 			updateImportsOnRename = true,
		-- 			lineLength = 80,
		-- 			renameFilesWithClasses = "prompt",
		-- 		},
		-- 	},
		-- })

		-- Setup mason-lspconfig
		require("mason-lspconfig").setup({
			ensure_installed = {
				"lua_ls",
				"pyright",
				"ts_ls",
				"tailwindcss",
				"emmet_language_server",
				"html",
				"cssls",
			},
		})
	end,
}

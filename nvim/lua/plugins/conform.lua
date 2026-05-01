return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_format" },
				javascript = { "biome" },
				typescript = { "biome" },
				javascriptreact = { "biome" },
				typescriptreact = { "biome" },
				json = { "prettier" },
				rust = { "rustfmt" },
				-- css/html etc. via biome or prettier as needed
			},
			formatters = {
				black = {
					prepend_args = { "--target-version", "py312" }, -- Force support for Python 3.12
				},
			},
			format_on_save = {
				timeout_ms = 3000, -- was your previous issue
				lsp_fallback = false,
			},
		})
	end,
}

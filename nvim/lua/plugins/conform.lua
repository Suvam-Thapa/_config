return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "black" },
				javascript = { "biome" },
				typescript = { "biome" },
				javascriptreact = { "biome" },
				typescriptreact = { "biome" },
				json = { "prettier" },
				-- css/html etc. via biome or prettier as needed
			},
			format_on_save = {
				timeout_ms = 3000, -- was your previous issue
				lsp_fallback = false,
			},
		})

		-- Manual format keymap (same as before)
		vim.keymap.set({ "n", "v" }, "<leader>f", function()
			require("conform").format({ async = false, lsp_fallback = false })
		end, { desc = "Format" })
	end,
}

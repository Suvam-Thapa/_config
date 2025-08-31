return {
	"echasnovski/mini.comment",
	version = false,
	dependencies = {
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("ts_context_commentstring").setup({
			enable_autocmd = false,
		})

		require("mini.comment").setup({
			options = {
				custom_commentstring = function()
					local ts_comment = require("ts_context_commentstring.internal").calculate_commentstring({
						key = "commentstring",
					})
					return ts_comment or vim.bo.commentstring
				end,
			},
		})
	end,
}

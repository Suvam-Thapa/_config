return {
	"brenoprata10/nvim-highlight-colors", -- correct repo name & spelling
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("nvim-highlight-colors").setup({
			render = "virtual",
		})
	end,
}

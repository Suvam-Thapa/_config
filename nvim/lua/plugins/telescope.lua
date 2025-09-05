return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	config = function()
		require("telescope").setup({
			defaults = {
				borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
			},
			-- pickers = {
			-- 	find_files = {
			-- 		theme = "dropdown",
			-- 	},
			-- },
			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
				},
			},
			require("telescope").load_extension("fzf"),
		})
	end,
	keys = {
		{
			"<leader>ff",
			function()
				require("telescope.builtin").find_files({
					search_dirs = {
						vim.fn.expand("~/.config/nvim"),
						vim.fn.expand("~/.config/alacritty"),
						vim.fn.getcwd(),
					},
				})
			end,
			desc = "Telescope find files",
		},
		{
			"<leader>fg",
			function()
				require("telescope.builtin").live_grep()
			end,
			desc = "Telescope live grep",
		},
		{
			"<leader>fb",
			function()
				require("telescope.builtin").buffers()
			end,
			desc = "Telescope buffers",
		},
		{
			"<leader>fh",
			function()
				require("telescope.builtin").help_tags()
			end,
			desc = "Telescope help tags",
		},
		{
			"<leader>h",
			function()
				vim.cmd("normal! y")
				local selected_text = vim.fn.getreg('"'):gsub("^%s+", ""):gsub("%s+$", ""):gsub("\n", " ")
				require("telescope.builtin").help_tags({ default_text = selected_text })
			end,
			mode = "v",
			desc = "Search help for selected text",
		},
	},
}

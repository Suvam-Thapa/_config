return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	lazy = true,
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	config = function()
		require("telescope").setup({
			defaults = {
				-- borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
				preview = false,
				-- preview = {
				-- 	treesitter = false,
				-- },
				mappings = {
					i = {
						["<C-j>"] = require("telescope.actions").move_selection_next,
						["<C-k>"] = require("telescope.actions").move_selection_previous,
						["<leader>q"] = require("telescope.actions").close,
					},
				},
			},
			pickers = {
				find_files = {
					theme = "dropdown",
				},
			},
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
			"<leader>p",
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
			"<leader>g",
			function()
				require("telescope.builtin").live_grep()
			end,
			desc = "Telescope live grep",
		},
		{
			"<leader>b",
			function()
				require("telescope.builtin").buffers()
			end,
			desc = "Telescope buffers",
		},
		{
			"<leader>h",
			function()
				require("telescope.builtin").help_tags()
			end,
			desc = "Telescope help tags",
		},
		{
			"<leader>hh",
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

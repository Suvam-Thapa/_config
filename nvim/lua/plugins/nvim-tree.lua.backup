return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = true,
	cmd = { "NvimTreeToggle" },
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup({
			disable_netrw = true,
			hijack_netrw = true,

			view = {
				float = {
					enable = true,
					quit_on_focus_loss = true,
					open_win_config = {
						relative = "win",
						border = "solid",
						width = 70,
						height = 16,
						-- col = (vim.o.columns - 70) / 2,
						-- row = (vim.o.lines - 16) / 2,
						col = math.floor((vim.api.nvim_win_get_width(0) - 70) / 2), -- Use window width
						row = math.floor((vim.api.nvim_win_get_height(0) - 16) / 2), -- Use window height
					},
				},
			},
			renderer = {
				icons = {
					glyphs = {
						folder = {
							default = "",
							open = "",
							empty = "",
							empty_open = "",
						},
					},
				},
			},
			update_focused_file = { enable = false },
			diagnostics = { enable = false },
		})
	end,
	keys = {
		{
			"<leader>e",
			function()
				require("nvim-tree.api").tree.toggle({ path = vim.uv.cwd() })
			end,
			desc = "Toggle file tree",
		},
	},
}

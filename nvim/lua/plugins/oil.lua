return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	lazy = false,
	config = function()
		require("oil").setup({
			default_file_explorer = true, -- replaces netrw
			delete_to_trash = true,
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = true, -- show dotfiles
				natural_sort = true,
			},
			win_options = {
				wrap = false,
				signcolumn = "no",
			},
			columns = {
				"icon",
				-- "git_status",
				-- "size",
			},
			keymaps = {
				["<CR>"] = "actions.select",
				["<BS>"] = "actions.parent", -- go up a directory
				["-"] = { "actions.parent", mode = "n" },
				["_"] = { "actions.open_cwd", mode = "n" },
				["<C-p>"] = "actions.preview",
				["<C-r>"] = "actions.refresh",
				["q"] = { "actions.close", mode = "n" },
				["gs"] = { "actions.change_sort", mode = "n" },
				["g."] = { "actions.toggle_hidden", mode = "n" },
			},
			use_default_keymaps = false, -- only use what's above
		})

		-- Open oil in current file's directory
		vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
	end,
}

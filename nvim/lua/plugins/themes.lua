-- return {
-- 	"catppuccin/nvim",
-- 	name = "catppuccin",
-- 	lazy = false,
-- 	priority = 1200,
-- 	config = function()
-- 		vim.cmd.colorscheme("catppuccin-latte")
-- 	end,
-- }
--
-- return {
-- 	"folke/tokyonight.nvim",
-- 	lazy = false,
-- 	priority = 1200,
-- 	opts = {},
-- 	config = function()
-- 		vim.cmd.colorscheme("tokyonight-day")
-- 	end,
-- }

return {
	"neanias/everforest-nvim",
	version = false,
	lazy = false,
	priority = 1200,
	config = function()
		require("everforest").setup({
			ui_contrast = "high",
		})
		vim.cmd.colorscheme("everforest")
	end,
}

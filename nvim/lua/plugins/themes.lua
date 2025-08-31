-- return {
-- 	"ptdewey/darkearth-nvim",
-- 	lazy = false,
-- 	priority = 1000,
-- 	config = function()
-- 		vim.cmd.colorscheme("darkearth")
-- 	end,
-- }

-- return {
-- 	"catppuccin/nvim",
-- 	name = "catppuccin",
-- 	lazy = true,
-- 	event = { "VeryLazy" },
-- 	priority = 1000,
-- 	config = function()
-- 		vim.cmd.colorscheme("catppuccin-mocha")
-- 	end,
-- }

return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1200,
	opts = {},
	config = function()
		vim.cmd.colorscheme("tokyonight-night")
	end,
}

-- return {
-- 	"catppuccin/nvim",
-- 	name = "catppuccin",
-- 	lazy = false,
-- 	priority = 1200,
-- 	config = function()
-- 		vim.cmd.colorscheme("catppuccin-latte")
-- 	end,
-- }

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
  "sainnhe/gruvbox-material",
  lazy = false,
  priority = 1000,
  config = function()
    -- Set options before loading the colorscheme
    vim.g.gruvbox_material_background = "soft"
    vim.g.gruvbox_material_better_performance = 1

    -- Load the colorscheme
    vim.cmd("colorscheme gruvbox-material")
  end,
}

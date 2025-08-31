return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			local autopairs = require("nvim-autopairs")

			autopairs.setup({
				check_ts = true, -- Enable Treesitter integration
				ts_config = {
					lua = { "string", "source" },
					javascript = { "string", "template_string" },
					typescript = { "string", "template_string" },
				},
				disable_filetype = { "TelescopePrompt", "vim" },
				map_cr = true, -- Map <CR> to handle pairs
				map_bs = false, -- Map backspace
				map_c_h = true, -- Don't map ctrl+h
			})
		end,
	},
}

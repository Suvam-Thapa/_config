return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			-- On main branch, setup() only accepts install_dir, nothing else
			require("nvim-treesitter").setup()

			-- Install parsers (replaces ensure_installed)
			require("nvim-treesitter").install({
				"lua",
				"python",
				"javascript",
				"typescript",
				"tsx",
				"html",
				"css",
				"tmux",
				"bash",
				"rust",
			})

			-- Highlighting + indentation: guarded so fake buffers (TelescopePrompt etc.) don't crash
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("treesitter_highlight_indent", { clear = true }),
				callback = function(ev)
					local ok = pcall(vim.treesitter.start, ev.buf)
					if ok then
						vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
					include_surrounding_whitespace = false,
				},
				move = {
					set_jumps = true,
				},
			})

			local select = require("nvim-treesitter-textobjects.select")
			local move = require("nvim-treesitter-textobjects.move")
			local swap = require("nvim-treesitter-textobjects.swap")

			-- Select text objects
			vim.keymap.set({ "x", "o" }, "af", function()
				select.select_textobject("@function.outer", "textobjects")
			end, { desc = "Select outer function" })
			vim.keymap.set({ "x", "o" }, "if", function()
				select.select_textobject("@function.inner", "textobjects")
			end, { desc = "Select inner function" })
			vim.keymap.set({ "x", "o" }, "ac", function()
				select.select_textobject("@class.outer", "textobjects")
			end, { desc = "Select outer class" })
			vim.keymap.set({ "x", "o" }, "ic", function()
				select.select_textobject("@class.inner", "textobjects")
			end, { desc = "Select inner class" })

			-- Swap
			vim.keymap.set("n", "<leader>k", function()
				swap.swap_next("@parameter.inner")
			end, { desc = "Swap next parameter" })
			vim.keymap.set("n", "<leader>j", function()
				swap.swap_previous("@parameter.inner")
			end, { desc = "Swap previous parameter" })

			-- Move
			vim.keymap.set({ "n", "x", "o" }, "]m", function()
				move.goto_next_start("@function.outer", "textobjects")
			end, { desc = "Next function start" })
			vim.keymap.set({ "n", "x", "o" }, "]c", function()
				move.goto_next_start("@class.outer", "textobjects")
			end, { desc = "Next class start" })
			vim.keymap.set({ "n", "x", "o" }, "[m", function()
				move.goto_previous_start("@function.outer", "textobjects")
			end, { desc = "Prev function start" })
			vim.keymap.set({ "n", "x", "o" }, "[c", function()
				move.goto_previous_start("@class.outer", "textobjects")
			end, { desc = "Prev class start" })

			-- Parameters
			vim.keymap.set({ "x", "o" }, "aa", function()
				select.select_textobject("@parameter.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ia", function()
				select.select_textobject("@parameter.inner", "textobjects")
			end)

			-- Conditionals
			vim.keymap.set({ "x", "o" }, "ai", function()
				select.select_textobject("@conditional.outer", "textobjects")
			end)

			vim.keymap.set({ "x", "o" }, "ii", function()
				select.select_textobject("@conditional.inner", "textobjects")
			end)

			-- Blocks {}
			vim.keymap.set({ "x", "o" }, "ab", function()
				select.select_textobject("@block.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ib", function()
				select.select_textobject("@block.inner", "textobjects")
			end)

			-- Loop
			vim.keymap.set({ "n", "x", "o" }, "]l", function()
				move.goto_next_start("@loop.outer", "textobjects")
			end)
			vim.keymap.set({ "n", "x", "o" }, "[l", function()
				move.goto_previous_start("@loop.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "al", function()
				select.select_textobject("@loop.outer", "textobjects")
			end, { desc = "Select outer loop" })
			vim.keymap.set({ "x", "o" }, "il", function()
				select.select_textobject("@loop.inner", "textobjects")
			end, { desc = "Select inner loop" })
		end,
	},
}

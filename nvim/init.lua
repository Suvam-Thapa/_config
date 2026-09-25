--[[
=== Options ===
--]]
vim.loader.enable()
vim.opt.background = "light"

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.scrolloff = 8

vim.opt.clipboard = "unnamedplus"

vim.opt.wrap = false

-- vim.opt.lazyredraw = true -- Delay redraw during macros
vim.opt.updatetime = 280 -- Faster cursor hold updates (default 4000ms)
vim.opt.timeoutlen = 280

--[[
=== KeyMaps ===
--]]

local opts = { noremap = true, silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "moves lines down in visual selection" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "moves line up in visual selection" })

-- Delete without copying to clipboard
vim.keymap.set("n", "dd", '"_dd', opts)
vim.keymap.set("v", "d", '"_d', opts)
vim.keymap.set("n", "x", '"_x', opts) -- prevent deleted characters from copying to clipboard

vim.keymap.set({ "i", "v" }, "QQ", "<Esc>", { desc = "Exit insert mode with QQ" })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("Highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Fast buffer next / prev
vim.keymap.set("n", "<leader>n", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>m", ":bprev<CR>", { desc = "Previous buffer" })

--[[
=== Imports ===
--]]

require("config.lazy")

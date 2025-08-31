local opts = { noremap = true, silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "moves lines down in visual selection" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "moves line up in visual selection" })

vim.keymap.set("n", "x", '"_x', opts) -- prevent deleted characters from copying to clipboard

vim.keymap.set({ "i", "v" }, "QQ", "<Esc>", { desc = "Exit insert mode with JJ " })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("Highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Just some shortcuts --

---- Navigation and movements ----

-- 0 == starting of line
-- $ == ending of line
-- gg == first line but same char placement
-- G == last line of file but same char placement
-- % == matching brace, parenthesis, bracket
-- f{char} == jump forward to that character
-- t{char} == jump just before to that char
-- H == jump to top
-- L == jump to bottom
-- M == jump to middle    of the screen
-- ctrl + u == scroll up
-- ctrl + d == scroll down
--

---- Editing and Manipulation ----

-- caw == change around the word
-- ciw == change inside the word
-- ca{char} and ci{char} == working with other text object
-- daw
-- diw
-- da{char} and di{char} == delete inside around the text
-- xp == swap the character under the cursor with next one (delete, paste)

---- Commands ----

-- :x == save and quit
-- :%s/{old}/{new} == Replace all occurance in the file

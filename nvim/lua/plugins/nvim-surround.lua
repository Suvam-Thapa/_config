return {
	"kylechui/nvim-surround",
	version = "^3.0.0",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("nvim-surround").setup({
			-- Configuration here, or leave empty to use defaults
			--     Old text                    Command         New text
			-- --------------------------------------------------------------------------------
			--     surr*ound_words             ysiw)           (surround_words)
			--     *make strings               ys$"            "make strings"
			--     [delete ar*ound me!]        ds]             delete around me!
			--     remove <b>HTML t*ags</b>    dst             remove HTML tags
			--     "change quot*es"            cs'"            "change quotes"
			--     <p>or tag* types</p>        csth1<CR>       <h1>or tag types</h1>
			--     delete(functi*on calls)     dsf             function calls
		})
	end,
}

-- IMPORTANT: Settings should be loaded before lazy plugin manager, needs to be
-- setup the mapleader and maplocalleader
require("config.settings")

require("config.keybindings")
require("config.highlight_yank_text")
require("config.lazy_setup")

local options = {
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
}

require("lazy").setup({
	spec = {
		import = "plugins",
	},

	checker = { enabled = true },
}, options)

vim.keymap.set("n", "<leader>n", ":bnext<CR>")

-- require("experiment.solution_explorer")

--[[
              ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
              ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
              ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
              ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
              ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
              ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
              " ------------------------------------------------
              Author: srdusr
               Email: graytrevor98@gmail.com
                 Url: https://github.com/srdusr/nvim.git
              ------------------------------------------------ "
--]]

--[[init.]]

-- ========================================================================== --
-- ==                            DEPENDENCIES                              == --
-- ========================================================================== --

-- ripgrep    - https://github.com/BurntSushi/ripgrep
-- fd         - https://github.com/sharkdp/fd
-- git        - https://git-scm.com/
-- make       - https://www.gnu.org/software/make/
-- c compiler - gcc or tcc or zig

-- -------------------------------------------------------------------------- --

-- ================================== --
-- ==    Install neovim-nightly    == --
-- ================================== --

-- Download nvim-linux64.tar.gz:
--$ curl -L -o nvim-linux64.tar.gz https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz
-- Extract:
--$ tar xzvf nvim-linux64.tar.gz
-- Run:
--$ ./nvim-linux64/bin/nvim

-- ---------------------------------- --

-- Initialize config with this one liner in the terminal
--$ nvim --headless -c 'call mkdir(stdpath("config"), "p") | exe "edit" stdpath("config") . "/init.lua" | write | quit'

-- Command to see startup time
--$ nvim --startuptime startup.log -c exit && tail -100 startup.log

-- Load impatient (Faster loading times)
local impatient_ok, impatient = pcall(require, "impatient")
if impatient_ok then
	impatient.enable_profile()
end


-- Schedule reading shadafile to improve the startup time
vim.opt.shadafile = "NONE"
vim.schedule(function()
	vim.opt.shadafile = ""
	vim.cmd("silent! rsh")
end)


-- Load/reload modules
local modules = {
  "user.pack", -- Packer plugin manager
  "user.opts", -- Options
  "user.keys", -- Keymaps
  "user.mods", -- Modules/functions
  --"user.deps", -- Plugins
  --"user.scripts",
  "plugins.colorscheme",
  "plugins.treesitter",
  "plugins.telescope",
  "plugins.nvim-tree",
  "plugins.quickfix",
  "plugins.cmp",
  "plugins.luasnip",
  "plugins.colorizer",
  "plugins.prettier",
  --"plugins.git",
  "plugins.gitsigns",
  "plugins.neoscroll",
  "plugins.null-ls",
  "plugins.lsp",
  "plugins.goto-preview",
  "plugins.autopairs",
  "plugins.web-devicons",
  "plugins.navic",
  "plugins.heirline",
  "plugins.zen-mode",
  "plugins.fidget",
  "plugins.toggleterm",
  "plugins.trouble",
  "plugins.dashboard",
  --"plugins.dap",
  --"plugins.modify-blend",
  --"plugins.floatterm",
}


-- Refresh module cache
for k, v in pairs(modules) do
  package.loaded[v] = nil
  require(v)
end


-- Check if we have the latest stable version of nvim
local mods = require("user.mods")
local expected_ver = "0.9.0"
local nvim_ver = mods.get_nvim_version()

if nvim_ver ~= expected_ver then
	local msg = string.format("Unsupported nvim version: expect %s, but got %s instead!", expected_ver, nvim_ver)
vim.api.nvim_err_writeln(msg)
	return
end


-- Snippets
vim.g.snippets = "luasnip"

-- Notifications
vim.notify = require("notify") -- Requires plugin "rcarriga/nvim-notify"

-- Improve speed by disabling some default plugins/modules
local builtins = {
	"gzip",
	"zip",
	"zipPlugin",
	"tar",
	"tarPlugin",
	"getscript",
	"getscriptPlugin",
	"vimball",
	"vimballPlugin",
	"2html_plugin",
	--"matchit",
	--"matchparen",
	"logiPat",
	"rrhelper",
	"netrw",
	"netrwPlugin",
	"netrwSettings",
	"netrwFileHandlers",
  "tutor_mode_plugin",
  "fzf",
  "spellfile_plugin",
  "sleuth",
}

for _, plugin in ipairs(builtins) do
	vim.g["loaded_" .. plugin] = 1
end
vim.g.do_filetype_lua = 1
vim.g.did_load_filetypes = 0

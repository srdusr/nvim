local fn = vim.fn

--------------------------------------------------

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer, please close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

--------------------------------------------------

-- Autocommand that reloads neovim whenever you save this file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost pack.lua source <afile> | PackerSync
  augroup end
]])

--------------------------------------------------

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

--------------------------------------------------

-- Have packer use a popup window and set a maximum number of jobs
packer.init({
	auto_reload_compiled = true,
	--max_jobs = 90,
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

--------------------------------------------------

-- Install plugins here
return packer.startup(function(use)
  -- Defaults
	use("wbthomason/packer.nvim") -- Have packer manage itself (package manager)
  use("nvim-lua/plenary.nvim") -- Useful lua functions used by lots of plugins
	use("lewis6991/impatient.nvim") -- Faster loading/startup times

  -- Tree-sitter
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }) -- For language parsing, examples: highlighting, folding, jumping, refactoring...
	use("nvim-treesitter/nvim-treesitter-refactor") -- Refactor module for nvim-treesitter

  -- lsp
  use("williamboman/mason.nvim") -- Package manager to install and manage LSP servers, DAP servers, linters and formatters
  use("williamboman/mason-lspconfig.nvim") -- Bridges mason.nvim with nvim-lspconfig to help use them together
  use("neovim/nvim-lspconfig") -- Collection of LSP configs
  use({
  "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  config = function()
    require("lsp_lines").setup()
  end,
  })
  use("rmagatti/goto-preview")

  -- neodev
  use("folke/neodev.nvim")

  -- Debugger
	use("mfussenegger/nvim-dap") -- Debug Adapter Protocol client implementation for Neovim
	use("rcarriga/nvim-dap-ui") -- UI for nvim-dap
  use("theHamsta/nvim-dap-virtual-text")
  use("gabrielpoca/replacer.nvim")
  use({
    "jayp0521/mason-nvim-dap.nvim",
    config = function()
      require("mason-nvim-dap").setup({
        automatic_installation = true,
        ensure_installed = { "python", "cppdbg", "codelldb" },
      })
    end,
  })

	-- Linters/Formatters
	use('mhartington/formatter.nvim')
	use("jay-babu/mason-null-ls.nvim")
	--use({"jayp0521/mason-null-ls.nvim",
  --  config = function()
  --  require('mason-null-ls.nvim').setup({
  --    automatic_setup = true,
  --  })
  --  end
  --})
  use({
		"jose-elias-alvarez/null-ls.nvim", -- Provides LSP: linters, formatters, diagnostics, code actions and etc...
		requires = { "jay-babu/mason-null-ls.nvim" },
	})

	-- Completion
  use("hrsh7th/nvim-cmp") -- Completion engine plugin
	use("hrsh7th/cmp-nvim-lsp") -- Completion source for nvim-lsp
	use("hrsh7th/cmp-buffer") -- Completion source for content of current buffer
	use("hrsh7th/cmp-path") -- Completion source for paths
	use("hrsh7th/cmp-cmdline") -- Completion source for command-line
  use("petertriho/cmp-git") -- Completion source for git
	use("tamago324/cmp-zsh") -- Completion source for zsh
	use("f3fora/cmp-spell") -- Completion source for spell-checking
	use("hrsh7th/cmp-calc") -- Completion source for math calculation
	use("saadparwaiz1/cmp_luasnip") -- Completion source for snippets, specifically for luasnip
	use("hrsh7th/cmp-nvim-lsp-signature-help") -- Completion source for displaying function signatures with the current parameter emphasized
  use("rcarriga/cmp-dap")

	-- Snippets
	use("L3MON4D3/LuaSnip") -- Snippet engine
	use("rafamadriz/friendly-snippets") -- Collection of snippets to use

	-- Git
	use("tpope/vim-fugitive") -- 
	--use("dinhhuy258/git.nvim") -- For git blame & browse
  use("kdheepak/lazygit.nvim") -- Terminal UI for git commands
	use("lewis6991/gitsigns.nvim") -- Git decorations

  -- File explorer/fuzzy finder
	use("kyazdani42/nvim-tree.lua") -- File explorer
	use('ibhagwan/fzf-lua') -- Fuzzy finder
	use('ThePrimeagen/harpoon')
	use("nvim-telescope/telescope.nvim") --  Fuzzy finder with lots of features/extendabilities
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" }) -- Support fzf syntax/algorithm
	use("nvim-telescope/telescope-ui-select.nvim") -- 
	use("nvim-telescope/telescope-media-files.nvim") -- 
	use("nvim-telescope/telescope-file-browser.nvim") -- 
	use({ "nvim-telescope/telescope-symbols.nvim", after = "telescope.nvim" }) -- Search emoji(s) and other symbols
	use("nvim-telescope/telescope-dap.nvim")
	use("axkirillov/telescope-changed-files") -- 

	-- UX
  use({
    'numToStr/Navigator.nvim', -- Navigate between Tmux and Nvim
    config = function()
        require('Navigator').setup()
    end,
  })
	use({ "tpope/vim-eunuch", cmd = { "Rename", "Delete" } }) -- Handy unix commands inside Vim (Rename, Move etc.)
	--use("tpope/vim-surround") -- 
	--use("tpope/vim-obsession") -- 
	--use("tpope/vim-unimpaired") -- 
	--use("vimpostor/vim-tpipeline") -- 
  --use("nathom/filetype.nvim") -- 
	use({"myusuf3/numbers.vim", -- 
    vim.cmd("let g:numbers_exclude = ['dashboard']")
  })
	use("windwp/nvim-autopairs") -- 
	use("numToStr/Comment.nvim") -- 
	use("akinsho/toggleterm.nvim") -- 
	use("tweekmonster/startuptime.vim") -- 
	use({
	  "ggandor/leap.nvim", -- 
	  config = function()
      require('leap').add_default_mappings()
	    --require("leap").set_default_keymaps()
      --vim.keymap.set('n', '-', '<Plug>(leap-forward)', {})
      --vim.keymap.set('n', '_', '<Plug>(leap-backward)', {})
	  end,
	})
  use({ "ggandor/flit.nvim", -- 
    config = function()
      require("flit").setup()
    end,
  })
	use("folke/which-key.nvim") -- 
	use("folke/zen-mode.nvim") -- 
	use("romainl/vim-cool") -- 
  use("antoinemadec/FixCursorHold.nvim") -- 
  use({
  "folke/trouble.nvim",
  requires = "nvim-tree/nvim-web-devicons",
  })
  use("airblade/vim-rooter") -- 
	--use("vim-test/vim-test") -- 
	--use({
	--  "rcarriga/vim-ultest", -- 
	--  requires = { "vim-test/vim-test" },
	--  run = ":UpdateRemotePlugins",
	--  config = function()
	--    require("plugins.ultest")
	--  end,
	--})
	use({"rcarriga/neotest",
    config = function()
    require("neotest").setup()
  end,
  })


	-- Colorschemes
	use("bluz71/vim-nightfly-guicolors")
	use("ayu-theme/ayu-vim")
	use("joshdick/onedark.vim")
	use("NTBBloodbath/doom-one.nvim")
	use("nyngwang/nvimgelion")

  -- UI
	use("kyazdani42/nvim-web-devicons") -- 
	use("onsails/lspkind-nvim") -- 
  use ({'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async'}) -- Fold code
  use ({"luukvbaal/statuscol.nvim",
    config = function()
    local builtin = require "statuscol.builtin"
    require("statuscol").setup {
      relculright = true,
      segments = {
        { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
        { text = { "%s" }, click = "v:lua.ScSa" },
        { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
      },
    }
    end
  })
  use({
    'glepnir/dashboard-nvim',
    event = 'VimEnter',
    requires = {'nvim-tree/nvim-web-devicons'}
  })
	use("rcarriga/nvim-notify") -- Notification plugin
	use("karb94/neoscroll.nvim") -- Faster/smooth scrolling
	use("MunifTanjim/prettier.nvim") -- Prettier plugin for Neovim's built-in LSP client
	use("norcalli/nvim-colorizer.lua") -- 
  use( "j-hui/fidget.nvim") -- UI to show nvim-lsp progress
  use { "simrat39/symbols-outline.nvim", -- 
    config = function()
      require("symbols-outline").setup({
        auto_close = true,
      })
    end
  }
  use({ "kosayoda/nvim-lightbulb", -- 
    requires = "antoinemadec/FixCursorHold.nvim",
  })
	use({
    "SmiteshP/nvim-navic", -- Statusline/Winbar component that uses LSP to show current code context
    requires = "neovim/nvim-lspconfig"
  })
  use({
    'rebelot/heirline.nvim', -- Statusline that is highly configurable
    requires = 'kyazdani42/nvim-web-devicons',
    event = 'VimEnter',
  })

  -- Language specific tools
  use("simrat39/rust-tools.nvim") -- Rust tooling ecosystem
  use({ "saecki/crates.nvim", -- 
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup()
    end,
  })
  use({
    "iamcco/markdown-preview.nvim", -- Markdown Preview
    run = function() vim.fn["mkdp#util#install"]() end,
  })
  use({
    "ellisonleao/glow.nvim", -- Markdown Preview
    config = function()
    require("glow").setup({
      style = "dark",
    })
  end
  })

--------------------------------------------------

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)

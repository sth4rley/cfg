--[settings ]]
vim.g.mapleader = " " -- Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a" -- enable mouse mode in "a"ll modes (can be useful for resizing splits for example)
vim.opt.showmode = false -- the mode is already in the status line
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300 -- mapped sequence wait time
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 10
vim.opt.cursorline = true
vim.opt.inccommand = "split" -- preview subs live, as you type
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.schedule(function() -- Schedule the settings after 'UiEnter' because it can increase startup-time.
	vim.opt.guifont = "JetBrainsMono Nerd Font:h12"
	vim.opt.clipboard = "unnamedplus" -- Sync clipboard between OS and Neovim
end)
vim.opt.list = false -- sets how neovim will display certain whitespace characters
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

--vim.keymap.set("n", "<space>fB", ":Telescope file_browser<CR>")

-- open file_browser with the path of the current buffer
--vim.keymap.set("n", "<space>fb", ":Telescope file_browser path=%:p:h select_buffer=true<CR>")

vim.keymap.set("n", "<space>o-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- [[ Keymaps ]]
vim.keymap.set("n", "<C-s>", function()
	vim.cmd("update")
	vim.notify("File saved!", vim.log.levels.INFO, { title = "Neovim" })
end, { desc = "Save file" })
vim.keymap.set("n", "<C-q>", function()
	vim.cmd("quit")
end, { desc = "Quit" })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>") -- clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" }) -- diagnostic keymaps
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" }) -- to make it easier to exit terminal mode
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<leader>bd", "<cmd>bd<CR>", { desc = "Delete current buffer" })

-- Tabpages
vim.keymap.set("n", "<leader><Tab>n", "<cmd>tabnew<CR>", { desc = "Tab: New" })
vim.keymap.set("n", "<leader><Tab>c", "<cmd>tabclose<CR>", { desc = "Tab: Close" })
vim.keymap.set("n", "<leader><Tab>o", "<cmd>tabonly<CR>", { desc = "Tab: Only (close others)" })
-- Jump straight to a tabpage by number: <leader>1 .. <leader>9
for i = 1, 9 do
	vim.keymap.set("n", "<leader>" .. i, i .. "gt", { desc = "Go to tab " .. i })
end

-- [[ Basic Autocommands ]]
--
-- Highlight when yanking (copying) text (Try it with `yap` in normal mode)
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins - :Lazy ]]
require("lazy").setup({
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
	{
		"ThePrimeagen/vim-be-good",
		cmd = "VimBeGood",
	},

	-- NOTE: Plugins can also be added by using a table,
	-- Use `opts = {}` to force a plugin to be loaded.

	-- Here is a more advanced example where we pass configuration
	-- options to `gitsigns.nvim`. This is equivalent to the following Lua:
	--    require('gitsigns').setup({ ... })
	--
	{ -- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},

	-- NOTE: Plugins can also be configured to run Lua code when they are loaded.
	--
	-- This is often very useful to both group configuration, as well as handle
	-- lazy loading plugins that don't need to be loaded immediately at startup.
	--
	-- For example, in the following configuration, we use:
	--  event = 'VimEnter'
	--
	-- which loads which-key before all the UI elements are loaded. Events can be
	-- normal autocommands events (`:help autocmd-events`).
	--
	-- Then, because we use the `opts` key (recommended), the configuration runs
	-- after the plugin has been loaded as `require(MODULE).setup(opts)`.

	{ -- Useful plugin to show you pending keybinds.
		"folke/which-key.nvim",
		event = "VimEnter", -- Sets the loading event to 'VimEnter'
		opts = {
			delay = 0, -- delay between pressing a key and opening which-key (this setting is independent of vim.opt.timeoutlen)
			icons = {
				mappings = vim.g.have_nerd_font, -- set icon mapping to true if you have a Nerd Font
				keys = {},
			},

			-- Document existing key chains
			spec = {
				{ "<leader>c", group = "[C]ode", mode = { "n", "x" } },
				{ "<leader>d", group = "[D]ocument" },
				{ "<leader>r", group = "[R]ename" },
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>w", group = "[W]orkspace" },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>u", group = "[U]I" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
			},
		},
	},

	{ -- Fuzzy Finder (files, lsp, etc)
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		cmd = "Telescope",
		keys = {
			{ "<leader>sh", "<cmd>Telescope help_tags<CR>", desc = "[S]earch [H]elp" },
			{ "<leader>sk", "<cmd>Telescope keymaps<CR>", desc = "[S]earch [K]eymaps" },
			{ "<leader>sf", "<cmd>Telescope find_files<CR>", desc = "[S]earch [F]iles" },
			{ "<leader>ss", "<cmd>Telescope builtin<CR>", desc = "[S]earch [S]elect Telescope" },
			{ "<leader>sw", "<cmd>Telescope grep_string<CR>", desc = "[S]earch current [W]ord" },
			{ "<leader>sg", "<cmd>Telescope live_grep<CR>", desc = "[S]earch by [G]rep" },
			{ "<leader>sd", "<cmd>Telescope diagnostics<CR>", desc = "[S]earch [D]iagnostics" },
			{ "<leader>sr", "<cmd>Telescope resume<CR>", desc = "[S]earch [R]esume" },
			{ "<leader>s.", "<cmd>Telescope oldfiles<CR>", desc = '[S]earch Recent Files ("." for repeat)' },
			{ "<leader><leader>", "<cmd>Telescope buffers<CR>", desc = "[ ] Find existing buffers" },
			{
				"<leader>uc",
				"<cmd>Telescope colorscheme enable_preview=true<CR>",
				desc = "[U]I [C]olorscheme (live preview)",
			},
			{
				"<leader>/",
				function()
					require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
						winblend = 10,
						previewer = false,
					}))
				end,
				desc = "[/] Fuzzily search in current buffer",
			},
			{
				"<leader>s/",
				function()
					require("telescope.builtin").live_grep({
						grep_open_files = true,
						prompt_title = "Live Grep in Open Files",
					})
				end,
				desc = "[S]earch [/] in Open Files",
			},
			{
				"<leader>sn",
				function()
					require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
				end,
				desc = "[S]earch [N]eovim files",
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ -- If encountering errors, see telescope-fzf-native README for installation instructions
				"nvim-telescope/telescope-fzf-native.nvim",

				-- `build` is used to run some command when the plugin is installed/updated.
				-- This is only run then, not every time Neovim starts up.
				build = "make",

				cond = function() -- condition to check if the plugin should be installed
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },

			-- Useful for getting pretty icons, but requires a Nerd Font.
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font }, -- preciso disso?
		},
		config = function()
			-- [[ Configure Telescope ]] -- See `:help telescope.setup()`, all the info is there
			require("telescope").setup({ -- Two important keymaps to use while in telescope are <c-/> and ?
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})

			-- Enable Telescope extensions if they are installed
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")
		end,
	},

	-- LSP Plugins
	{
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		-- Main LSP Configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for Neovim
			-- Mason must be loaded before its dependents so we need to set it up here.
			-- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
			{ "williamboman/mason.nvim", opts = {} },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP.
			{
				"j-hui/fidget.nvim",
				opts = {},
			},

			-- Allows extra capabilities provided by nvim-cmp
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- Language Servers are external tools that must be installed separately from
			-- Neovim. This is where `mason` and related plugins come into play.

			--  This function gets run when an LSP attaches to a particular buffer.
			--    That is to say, every time a new file is opened that is associated with
			--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
			--    function will be executed to configure the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					-- NOTE: Remember that Lua is a real programming language, and as such it is possible
					-- to define small helper and utility functions so you don't have to repeat yourself.
					--
					-- In this case, we create a function that lets us more easily define mappings specific
					-- for LSP related items. It sets the mode, buffer and description for us each time.
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end
					local telescope = function(picker)
						return function()
							require("telescope.builtin")[picker]()
						end
					end

					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					--  To jump back, press <C-t>.
					map("gd", telescope("lsp_definitions"), "[G]oto [D]efinition") -- definition of the word under your cursor
					map("gr", telescope("lsp_references"), "[G]oto [R]eferences") -- references for the word under your cursor

					-- Jump to the implementation of the word under your cursor.
					--  Useful when your language has ways of declaring types without an actual implementation.
					map("gI", telescope("lsp_implementations"), "[G]oto [I]mplementation")
					map("<leader>D", telescope("lsp_type_definitions"), "Type [D]efinition") -- type definition of the word under your cursor

					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					map("<leader>ds", telescope("lsp_document_symbols"), "[D]ocument [S]ymbols")

					-- Fuzzy find all the symbols in your current workspace.
					--  Similar to document symbols, except searches over your entire project.
					map("<leader>ws", telescope("lsp_dynamic_workspace_symbols"), "[W]orkspace [S]ymbols")

					-- Rename the variable under your cursor.
					--  Most Language Servers support renaming across files, etc.
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header.
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					-- The following code creates a keymap to toggle inlay hints in your
					-- code, if the language server you are using supports them
					-- This may be unwanted, since they displace some of your code
					if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(
								not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }),
								{ bufnr = event.buf }
							)
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})
			--
			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			-- Enable the following language servers
			local servers = { -- :help lspconfig-all for a list of all available LSPs
				pyright = {
					settings = {
						python = {
							analysis = {
								typeCheckingMode = "basic",
								useLibraryCodeForTypes = true,
								autoSearchPaths = true,
								diagnosticMode = "openFilesOnly",
							},
						},
					},
				},
				-- clangd = {},
				lua_ls = {
					-- cmd = { ... },
					-- filetypes = { ... },
					-- capabilities = {},
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							diagnostics = { disable = { "missing-fields" } }, -- to ignore Lua_LS's noisy `missing-fields` warnings
						},
					},
				},
			}

			-- Ensure the servers and tools above are installed - :Manson to see status of installed tools
			-- `mason` had to be setup earlier: to configure its options see the
			-- `dependencies` table for `nvim-lspconfig` above.
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, { -- you can add more tools here
				"stylua", -- Used to format Lua code
				"ruff", -- Used to format Python code
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			for server_name, server in pairs(servers) do
				server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
				vim.lsp.config(server_name, server)
			end

			require("mason-lspconfig").setup({
				automatic_enable = vim.tbl_keys(servers),
			})
		end,
	},

	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				-- Disable "format_on_save lsp_fallback" for languages that don't
				-- have a well standardized coding style. You can add additional
				-- languages here or re-enable it for the disabled ones.
				local disable_filetypes = { c = true, cpp = true }
				local lsp_format_opt
				if disable_filetypes[vim.bo[bufnr].filetype] then
					lsp_format_opt = "never"
				else
					lsp_format_opt = "fallback"
				end
				return {
					timeout_ms = 500,
					lsp_format = lsp_format_opt,
				}
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_format" },
				-- Conform can also run multiple formatters sequentially
				-- python = { "isort", "black" },
				--
				-- You can use 'stop_after_first' to run the first available formatter from the list
				-- javascript = { "prettierd", "prettier", stop_after_first = true },
			},
		},
	},

	{ -- Autocompletion
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			{
				"L3MON4D3/LuaSnip",
				build = (function()
					-- Build Step is needed for regex support in snippets.
					-- This step is not supported in many windows environments.
					-- Remove the below condition to re-enable on windows.
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					-- `friendly-snippets` contains a variety of premade snippets.
					--    See the README about individual language/framework/plugin snippets:
					--    https://github.com/rafamadriz/friendly-snippets
					-- {
					--   'rafamadriz/friendly-snippets',
					--   config = function()
					--     require('luasnip.loaders.from_vscode').lazy_load()
					--   end,
					-- },
				},
			},
			"saadparwaiz1/cmp_luasnip",

			-- Adds other completion capabilities.
			--  nvim-cmp does not ship with all sources by default. They are split
			--  into multiple repos for maintenance purposes.
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
		},
		config = function() -- see `:help cmp` for more information
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			luasnip.config.setup({})

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },

				-- For an understanding of why these mappings were
				-- chosen, you will need to read `:help ins-completion`
				--
				-- No, but seriously. Please read `:help ins-completion`, it is really good!
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(), -- ou <C-n> <Tab>
					["<C-p>"] = cmp.mapping.select_prev_item(), -- ou <C-p> <S-Tab>
					["<Tab>"] = cmp.mapping.confirm({ select = true }), -- ou <C-y> <CR>
					["<C-Space>"] = cmp.mapping.complete({}), -- Manually trigger completion

					-- Scroll the documentation window [b]ack / [f]orward
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),

					-- Think of <c-l> as moving to the right of your snippet expansion.
					--  So if you have a snippet that's like:
					--  function $name($args)
					--    $body
					--  end
					--
					-- <c-l> will move you to the right of each of the expansion locations.
					-- <c-h> is similar, except moving you backwards.
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),

					-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
					--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
				}),
				sources = {
					{
						name = "lazydev",
						group_index = 0, -- set to 0 to skip loading LuaLS completions as lazydev recommends it
					},
					{ name = "nvim_lsp" },
					{ name = "path" },
					{ name = "luasnip" },
				},
			})
		end,
	},

	--	{
	--		"jesseleite/nvim-noirbuddy",
	--		dependencies = {
	--			{ "tjdevries/colorbuddy.nvim" },
	--		},
	--		lazy = false,
	--		priority = 1000,
	--		opts = {
	--			preset = "miami-nights",
	--		},
	--	},

	-- Colorschemes
	{
		--"wtfox/jellybeans.nvim",
		"nyoom-engineering/oxocarbon.nvim",
		lazy = false,
		priority = 1000, -- load the active colorscheme first
	},
	-- Extra colorschemes (registered at startup so they show in :Telescope colorscheme;
	-- loading them only makes the theme available, it does not apply it)
	{ "ceigh/vercel-theme.nvim", lazy = false },
	{ "pmouraguedes/neodarcula.nvim", lazy = false },
	{ "hendriknielaender/stardust.nvim", lazy = false },
	{ "xero/miasma.nvim", lazy = false },
	{ "oskarnurm/koda.nvim", lazy = false },
	{ "jpwol/thorn.nvim", lazy = false },
	{ "alexpasmantier/hubbamax.nvim", lazy = false },

	-- Highlight todo, notes, etc in comments
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	{ -- Collection of various small independent plugins/modules
		"echasnovski/mini.nvim",
		config = function()
			-- Better Around/Inside textobjects
			-- Examples:
			--  - va)  - [V]isually select [A]round [)]paren
			--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
			--  - ci'  - [C]hange [I]nside [']quote
			require("mini.ai").setup({ n_lines = 500 })

			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
			-- - sd'   - [S]urround [D]elete [']quotes
			-- - sr)'  - [S]urround [R]eplace [)] [']
			require("mini.surround").setup()

			-- Indent scope highlight
			require("mini.indentscope").setup({
				symbol = "│", -- Você pode trocar o símbolo se quiser
				options = { try_as_border = true },
			})

			-- Autopairs (mini.pairs)
			require("mini.pairs").setup()

			-- Simple and easy statusline.
			local statusline = require("mini.statusline")
			statusline.setup({ use_icons = vim.g.have_nerd_font }) -- use icons if you have a Nerd Font

			-- set the section for cursor location to LINE:COLUMN
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end
		end,
	},

	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local languages = {
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"vim",
				"vimdoc",
			}

			local treesitter = require("nvim-treesitter")
			treesitter.setup({})
			treesitter.install(languages)

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
				callback = function(event)
					local lang = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
					if not lang or not vim.tbl_contains(languages, lang) then
						return
					end

					if pcall(vim.treesitter.start, event.buf, lang) and lang ~= "ruby" then
						vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},

	--	{
	--		"nvim-telescope/telescope-file-browser.nvim",
	--		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
	-- },

	{
		"stevearc/oil.nvim",
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {},
		-- Optional dependencies
		dependencies = { { "echasnovski/mini.icons", opts = {} } },
		-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
		lazy = false,
	},
	-- For `plugins.lua` users.
	{
		-- WARN: Do not lazy load this plugin as it is already lazy-loaded. Lazy-loading may cause more time for the previews to load when starting Neovim!
		"OXY2DEV/markview.nvim",
		lazy = false,

		-- Completion for `blink.cmp`
		-- dependencies = { "saghen/blink.cmp" },
	},
})

--vim.cmd([[colorscheme jellybeans-muted]])
--
vim.opt.background = "dark"
vim.cmd.colorscheme("oxocarbon")

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
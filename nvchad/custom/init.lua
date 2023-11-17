vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ruler = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 0
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.linebreak = true

vim.opt.lazyredraw = true

-- FIXME: Is this still needed?
-- Required by LanguageClient-neovim for operations modifying multiple buffers like rename.
vim.opt.laststatus = 2
vim.opt.hidden = true

-- Aligned visual block
vim.opt.virtualedit = "block"

-- Intuitive backspacing.
vim.opt.backspace = "indent,eol,start"

vim.opt.mouse = "a"

vim.opt.undodir = os.getenv("HOME") .. "/.local/share/nvim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

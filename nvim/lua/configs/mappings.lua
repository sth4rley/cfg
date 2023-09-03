-- Sair com 'q' , se usar gravação de macros altere para <C-q> → Ctrl + q
-- vim.cmd([[ map q :q<CR> ]])

-- Para Salvar com 'Ctrl + S' nos modos: Normal, Inserção e Visual
-- Precisa adicionar a linha: stty -ixon , ao seu ~/.bashrc
vim.cmd([[ nnoremap <C-s> :w<CR> ]])
vim.cmd([[ inoremap <C-s> <Esc>:w<CR>l ]])
vim.cmd([[ vnoremap <C-s> <Esc>:w<CR> ]])

-- Selecionar tudo com 'Ctrl + A'
vim.cmd([[ map <C-a> ggVG ]])

-- Definicao da leader
vim.g.mapleader = ' '

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- Configuração do toggleterm.nvim
vim.g.toggleterm_terminal_mapping = '<c-t>' -- Mapeamento para abrir/fechar o terminal

-- Mapeamentos para abrir terminais horizontal e vertical
vim.api.nvim_set_keymap('n', '<Leader>th', ':ToggleTerm direction=horizontal<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>tv', ':ToggleTerm direction=vertical<CR>', { noremap = true, silent = true })

-- use esc to exit terminal mode
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true })

-- keys to switch between windows
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })

-- Format Keys
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { remap = false })

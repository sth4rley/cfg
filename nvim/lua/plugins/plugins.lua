vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  use 'wbthomason/packer.nvim'
  use 'terroo/vim-simple-emoji'
  use 'navarasu/onedark.nvim'
  use {
  "jesseleite/nvim-noirbuddy",
  requires = { "tjdevries/colorbuddy.nvim", branch = "dev" }
  }

  use {
  'nvim-telescope/telescope.nvim',
  requires = { {'nvim-lua/plenary.nvim'} }
  }

  use {"akinsho/toggleterm.nvim", tag = '*', config = function()
  require("toggleterm").setup{
    size =  function(term)
    
    if term.direction == "horizontal" then
      return 10
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
    -- setup toggleterm to act like a sidebar

  end,
  
  }
  end}

  use 'yamatsum/nvim-cursorline'

  -- formatter
  use {
  'jose-elias-alvarez/null-ls.nvim',
  requires = { {'nvim-lua/plenary.nvim'} }
  }

  use {
    'goolord/alpha-nvim',
    requires = { 'nvim-tree/nvim-web-devicons' },
    config = function ()
        require'alpha'.setup(require'alpha.themes.startify'.config)
    end
}



end)

{config,pkgs,...}:

{

    programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      gruvbox-community
      gitsigns-nvim
      nvim-treesitter.withAllGrammars
      telescope-nvim
      telescope-fzf-native-nvim


      nvim-lspconfig
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      nvim-cmp
      luasnip

    ];
    extraLuaConfig = ''
      local indent = 2
      vim.opt.completeopt = { 'menu', 'menuone', 'noselect' } -- Completion options
      vim.opt.cursorline = true                               -- Highlight cursor line
      vim.opt.expandtab = true                                -- Use spaces instead of tabs
      vim.opt.hidden = true                                   -- Enable background buffers
      vim.opt.ignorecase = true                               -- Ignore case
      vim.opt.joinspaces = false                              -- No double spaces with join
      vim.opt.list = true                                     -- Show some invisible characters
      vim.opt.number = true                                   -- Show line numbers
      vim.opt.relativenumber = true                           -- Relative line numbers
      vim.opt.scrolloff = 4                                   -- Lines of context
      vim.opt.shell = 'bash --login'
      vim.opt.shiftround = true                               -- Round indent
      vim.opt.shiftwidth = indent                             -- Size of an indent
      vim.opt.sidescrolloff = 8                               -- Columns of context
      vim.opt.signcolumn = 'yes'
      vim.opt.smartcase = true                                -- Do not ignore case with capitals
      vim.opt.smartindent = true                              -- Insert indents automatically
      vim.opt.splitbelow = true                               -- Put new windows below current
      vim.opt.splitright = true                               -- Put new windows right of current
      vim.opt.tabstop = indent                                -- Number of spaces tabs count for
      vim.opt.termguicolors = true                            -- True color support
      vim.opt.wildmode = { 'list', 'longest' }                -- Command-line completion mode
      vim.opt.wrap = false                                    -- Disable line wrap

      vim.g.mapleader = ' '

      vim.cmd 'colorscheme gruvbox'

      local builtin =  require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})


      local cmp = require('cmp')


      cmp.setup({
        sources = {
          {name = 'path'},
          {name = 'nvim_lsp'},
          {name = 'buffer', keyword_length = 3},
        },
      })

      require'lspconfig'.bashls.setup{}

    '';
  };

}

{ pkgs, ... }:

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
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
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

      -- Add additional capabilities supported by nvim-cmp
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local lspconfig = require('lspconfig')

      -- Enable some language servers with the additional completion capabilities offered by nvim-cmp
      local servers = { 'bashls','nil_ls'}
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
          -- on_attach = my_custom_on_attach,
          capabilities = capabilities,
        }
      end

      -- luasnip setup
      local luasnip = require 'luasnip'

      -- nvim-cmp setup
      local cmp = require 'cmp'
      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
          ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
          -- C-b (back) C-f (forward) for snippet placeholder navigation.
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        },
      } 

    '';
  };

}

{ config, pkgs, ssh-key, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "charper";
  home.homeDirectory = "/home/charper";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.packages = [
    pkgs.ripgrep #nvim telescope
  ];

  programs.bash.enable = true;
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = [
      pkgs.vimPlugins.gruvbox-community
      pkgs.vimPlugins.gitsigns-nvim
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
      pkgs.vimPlugins.telescope-nvim
      pkgs.vimPlugins.telescope-fzf-native-nvim

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
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

    '';
  };
  
  programs.tmux = { 
	  enable = true;
	  clock24 = true;
	  keyMode = "vi";
	  mouse = false;
    terminal = "screen-256color";
	  shortcut = "a";
    extraConfig =''
      
      set-option -sa terminal-features ',xterm-kitty:RGB'
      bind -r -N 'Select panel to right' h select-pane -L
      bind -r -N 'Select panel to below' j select-pane -D
      bind -r -N 'Select panel to above' k select-pane -U
      bind -r -N 'Select panel to left'  l select-pane -R

      unbind Up     
      unbind Down   
      unbind Left   
      unbind Right  

      bind -r -N 'Increase panel to left' 'C-h' resize-pane -L 5
      bind -r -N 'Increase panel to below' 'C-j' resize-pane -D 5
      bind -r -N 'Increase panel to above' 'C-k' resize-pane -U 5
      bind -r -N 'Increase panel to right' 'C-l' resize-pane -R 5

      unbind C-Up   
      unbind C-Down 
      unbind C-Left 
      unbind C-Right


      bind c new-window -c '#{pane_current_path}'
      bind '"' split-window -c '#{pane_current_path}'
      bind % split-window -h -c '#{pane_current_path}'
	  '';
  };

  programs.git = {
	  enable = true;
	  userEmail = "charper+git@charper.co.uk";
	  userName = "Chris Harper";
	  extraConfig = {
      user = {
        signingkey = "key::${ssh-key}";
      };
      commit = {
        gpgsign = true;
      };
      gpg = {
        format = "ssh";
      };
	  };
  };
}

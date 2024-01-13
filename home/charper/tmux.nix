{ ... }:
{
  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    mouse = false;
    terminal = "screen-256color";
    shortcut = "a";
    extraConfig = ''
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


    '';
  };
}

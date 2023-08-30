{ username, ... }:

{
	home.stateVersion = "23.05";

# Let Home Manager install and manage itself.
	programs.home-manager.enable = true;

	programs.zsh = {
		enable = true;
		initExtra = ''
			eval "$(/opt/homebrew/bin/brew shellenv)"
			'';
	};

	home.sessionVariables={
		SSH_AUTH_SOCK = "/Users/${username}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
	};

	programs.kitty = {
		enable = true;
		theme = "Gruvbox Material Dark Hard";
	};

	programs.ssh = {
		enable=true;
		matchBlocks = {
			"*" = { 
				extraOptions.IdentityAgent = "/Users/${username}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
			};
			"nixos-vmware.local" = {
				forwardAgent= true;
			};
		};
	};
}

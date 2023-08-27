{ config, pkgs, ssh-key, ... }:

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
		SSH_AUTH_SOCK = "/Users/charper/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
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

	programs.ssh = {
		enable=true;
		matchBlocks = {
			"*" = { 
				extraOptions.IdentityAgent = "/Users/charper/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
			};
			"nixos-vmware.local" = {
				forwardAgent= true;
			};
		};
	};
}

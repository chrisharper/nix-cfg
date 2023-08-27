# Connectivity info for Linux VM
NIXADDR ?= unset
NIXPORT ?= 22
NIXUSER ?= charper

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# SSH options that are used. These aren't meant to be overridden but are
# reused a lot so we just store them up here.
SSH_OPTIONS=-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

# bootstrap a brand new VM. The VM should have NixOS ISO on the CD drive
# and just set the password of the root user to "root". This will install
# NixOS. After installing NixOS, you must reboot and set the root password
# for the next step.
#
# NOTE(mitchellh): I'm sure there is a way to do this and bootstrap all
# in one step but when I tried to merge them I got errors. One day.
vm/bootstrap0:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		parted /dev/sda -- mklabel gpt; \
		parted /dev/sda -- mkpart primary 512MB -8GB; \
		parted /dev/sda -- mkpart primary linux-swap -8GB 100\%; \
		parted /dev/sda -- mkpart ESP fat32 1MB 512MB; \
		parted /dev/sda -- set 3 esp on; \
		sleep 1; \
		mkfs.ext4 -L nixos /dev/sda1; \
		mkswap -L swap /dev/sda2; \
		mkfs.fat -F 32 -n boot /dev/sda3; \
		sleep 1; \
		mount /dev/disk/by-label/nixos /mnt; \
		mkdir -p /mnt/boot; \
		mount /dev/disk/by-label/boot /mnt/boot; \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\.stateVersion = .*/a \
		nix.package = pkgs.nixUnstable;\n \
		nix.extraOptions = \"experimental-features = nix-command flakes\";\n \
		services.openssh.enable = true;\n \
		services.openssh.settings.PasswordAuthentication = true;\n \
		services.openssh.settings.PermitRootLogin = \"yes\";\n \
		users.users.root.initialPassword = \"root\";\n \
		' /mnt/etc/nixos/configuration.nix; \
		nixos-install --no-root-passwd && reboot; \
		"

# after bootstrap0, run this to finalize. After this, do everything else
# in the VM unless secrets change.
vm/bootstrap:
	NIXUSER=root $(MAKE) vm/copy
	NIXUSER=root $(MAKE) vm/switch
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo reboot; \
	"

# copy the Nix configurations into the VM.
vm/copy:
	rsync -av -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
		--rsync-path="sudo rsync" \
 		$(MAKEFILE_DIR)/ $(NIXUSER)@$(NIXADDR):/nix-cfg

# run the nixos-rebuild switch command. This does NOT copy files so you
# have to run vm/copy before.
vm/switch:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nix-shell -p git --run 'nixos-rebuild switch --flake \/nix-cfg\#nixos-vmware ' \
									    "
#Installs Homebrew(pulls in xcode-tools) + Nix and setups build env
osx/bootstrap0:
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
	curl -L https://nixos.org/nix/install | sh
	nix build .#darwinConfigurations.darwin-m1air.system --extra-experimental-features nix-command --extra-experimental-features flakes 
	$(MAKE) osx/build

#run build for 
osx/build:
	./result/sw/bin/darwin-rebuild switch --flake .#darwin-m1air 
	/bin/zsh -c 'source ~/.zshrc'

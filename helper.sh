#!/bin/sh
#
#Boot VM with SATA disk.
#sudo su
#passwd root -> set to root
#ifconfig 

function vm_bootstrap {

	if [[ $# -eq 0 ]] ; then
 		echo 'requires IP of VM as arg'
		exit 1
	fi
  echo "Bootstrap NixOS"
	ssh root@$1 " \
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
		nix.extraOptions = \"experimental-features = nix-command flakes\";\n \
		services.openssh.enable = true;\n \
		services.openssh.settings.PasswordAuthentication = true;\n \
		services.openssh.settings.PermitRootLogin = \"yes\";\n \
		users.users.root.initialPassword = \"root\";\n \
		' /mnt/etc/nixos/configuration.nix; \
		nixos-install --no-root-passwd && reboot; \
		"
    echo "Sleeping for VM reboot"
    sleep 15

    echo "Copying config"
	  rsync -av --delete -e 'ssh -o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' $PWD/ root@$1:/etc/nixos

    echo "rebuilding flake"
	  ssh -o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$1 " \
        sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nix-shell -p git --run 'nixos-rebuild switch --flake /etc/nixos#nixos-vmware'; \
        sudo reboot; "

    echo "Setup Complete"
    exit 0


}

function osx_bootstrap {
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
	curl -L https://nixos.org/nix/install | sh
	nix build .#darwinConfigurations.darwin-m1air.system --extra-experimental-features nix-command --extra-experimental-features flakes 
	osx-build
}

function osx_build {
	./result/sw/bin/darwin-rebuild switch --flake .#darwin-m1air 
}

# Check if the function exists (bash specific)
if declare -f "$1" > /dev/null
then
  # call arguments verbatim
  "$@"
else
  # Show a helpful error
  echo "vm_bootstrap <ip>: bootstrap a vm at given IP  "
  echo "osx_bootstrap: bootstrap an OSX system with homebrew/nix and run flake"
  echo "osx_build: rebuild the OSX flake"
  exit 1
fi

"$@"

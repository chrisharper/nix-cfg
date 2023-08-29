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
  ssh_opts='-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

  echo "Bootstrap NixOS"
  ssh $ssh_opts root@$1 "mkdir /root/nix-cfg"
  scp -r $ssh_opts ./ root@$1:/root/nix-cfg
	ssh $ssh_opts root@$1 " \
		parted /dev/nvme0n1 -- mklabel gpt; \
		parted /dev/nvme0n1 -- mkpart primary 512MB -8GB; \
		parted /dev/nvme0n1 -- mkpart primary linux-swap -8GB 100\%; \
		parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB; \
		parted /dev/nvme0n1 -- set 3 esp on; \
		sleep 1; \
		mkfs.ext4 -L nixos /dev/nvme0n1p1; \
		mkswap -L swap /dev/nvme0n1p2; \
		mkfs.fat -F 32 -n boot /dev/nvme0n1p3; \
		sleep 1; \
		mount /dev/disk/by-label/nixos /mnt; \
		mkdir -p /mnt/boot; \
		mount /dev/disk/by-label/boot /mnt/boot; \
		nixos-generate-config --root /mnt; \
	  nix-shell -p git --command 'nixos-install --no-root-passwd --flake nix-cfg/#nixos-vmware'; \
    cp -rf nix-cfg /mnt/home/charper/nix-cfg; \
    nixos-enter -c 'chown -R charper /home/charper/nix-cfg; rm -rf /etc/nixos; ln -s /home/charper/nix-cfg /etc/nixos ;' && reboot; \
		"
  echo "Complete"
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

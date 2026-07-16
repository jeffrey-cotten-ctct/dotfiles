# btrfs-manager

An interactive CLI tool for managing btrfs subvolumes and a `ctct_products` symlink pointing to the active working directory.

## Setup

See the following link for how to set up btrfs on Linux:

[Setup Guide](https://docs.google.com/document/d/1xSnzSyoBNaUAzqncXu2CDbh-OrccJKUyYuTQhqqLPeM/edit?usp=sharing)

## Usage

```bash
./btrfs-manager.sh
```

On launch the script shows the current `ctct_products` symlink target and presents a menu with the following options:

### Switch btrfs symlink

Updates the `ctct_products` symlink to point to a selected subdirectory. After switching, if the target directory is a git repo and its current branch ticket ID doesn't match the directory name, the script offers to check out a matching branch automatically.

### Create a btrfs clone of a directory

Creates a btrfs snapshot of a selected directory under a new name. Optionally switches the `ctct_products` symlink to the new clone immediately after creation.

### Delete a btrfs volume

Deletes a btrfs subvolume. Requires two confirmation prompts to prevent accidental deletion. If the `ctct_products` symlink points to the deleted volume, the symlink is also removed. The script shows space usage before deletion, then deletes the subvolume without waiting for a reclaim sync or running a post-delete usage check.

### Check real space usage

Runs `btrfs filesystem usage -b` on the script directory to show total, used, and free space with a usage bar. The script first tries non-interactive sudo and then prompts for sudo credentials only if needed.

### Check btrfs shared-space savings

Runs `btrfs filesystem du -s --raw` on the script directory to show:
- Total bytes
- Exclusive bytes
- Set-shared bytes
- Savings from shared extents (bytes and percent)

This helps quantify the CoW space savings from snapshots/clones. Like the real space usage command, it falls back to prompting for sudo credentials when required.

### List all snapshots

Runs `btrfs subvolume list` on the script directory to list all subvolumes and snapshots.

## Requirements

- Linux with btrfs filesystem
- `btrfs-progs` installed (`btrfs` CLI available)
- Bash 4.0+
- Sudo access for operations that require elevated btrfs metadata reads or subvolume changes

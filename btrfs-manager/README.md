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

Deletes a btrfs subvolume. Requires two confirmation prompts to prevent accidental deletion. If the `ctct_products` symlink points to the deleted volume, the symlink is also removed.

### Check real space usage

Runs `btrfs filesystem usage` on the script directory to show actual disk usage, accounting for btrfs deduplication and shared extents.

### List all snapshots

Runs `btrfs subvolume list` on the script directory to list all subvolumes and snapshots.

## Requirements

- Linux with btrfs filesystem
- `btrfs-progs` installed (`btrfs` CLI available)
- Bash 4.0+

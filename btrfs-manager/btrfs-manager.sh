#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYMLINK="$SCRIPT_DIR/ctct_products"

# Collect candidate directories (exclude the symlink itself)
mapfile -t dirs < <(find "$SCRIPT_DIR" -maxdepth 1 -mindepth 1 -type d ! -name "ctct_products" -printf "%f\n" | sort)

if [[ ${#dirs[@]} -eq 0 ]]; then
    echo "No directories found."
    exit 1
fi

current_target="$(readlink "$SYMLINK" 2>/dev/null || echo "(none)")"
echo "Current symlink: ctct_products -> $current_target"
echo ""
echo "What would you like to do?"
echo "  1) Switch to a directory"
echo "  2) Create a btrfs clone of a directory"
echo "  3) Delete a btrfs volume"
echo ""

read -rp "Enter choice [1-3]: " main_choice

case "$main_choice" in
    1)
        echo ""
        echo "Select a directory to switch to:"
        select dir in "${dirs[@]}"; do
            if [[ -n "$dir" ]]; then
                ln -sfn "$dir" "$SYMLINK"
                echo "Updated: ctct_products -> $dir"
                break
            else
                echo "Invalid selection. Please try again."
            fi
        done
        ;;
    2)
        echo ""
        echo "Select a directory to clone:"
        select src_dir in "${dirs[@]}"; do
            if [[ -n "$src_dir" ]]; then
                break
            else
                echo "Invalid selection. Please try again."
            fi
        done

        echo ""
        while true; do
            read -rp "Enter a name for the clone: " -i "ctct_products-" -e clone_name

            if [[ -z "$clone_name" ]]; then
                echo "Clone name cannot be empty. Please try again."
                continue
            fi

            clone_path="$SCRIPT_DIR/$clone_name"

            if [[ -e "$clone_path" ]]; then
                echo "Error: '$clone_name' already exists. Please choose a different name."
                continue
            fi

            break
        done

        echo "Creating btrfs snapshot: $src_dir -> $clone_name ..."
        btrfs subvolume snapshot "$SCRIPT_DIR/$src_dir" "$clone_path"
        echo "Clone created: $clone_name"

        echo ""
        read -rp "Switch to '$clone_name' now? [y/N]: " switch_choice
        if [[ "$switch_choice" =~ ^[Yy]$ ]]; then
            ln -sfn "$clone_name" "$SYMLINK"
            echo "Updated: ctct_products -> $clone_name"
        else
            echo "Symlink unchanged: ctct_products -> $current_target"
        fi
        ;;
    3)
        echo ""
        echo "Select a volume to delete:"
        select del_dir in "${dirs[@]}"; do
            if [[ -n "$del_dir" ]]; then
                break
            else
                echo "Invalid selection. Please try again."
            fi
        done

        echo ""
        read -rp "Are you sure you want to delete '$del_dir'? [y/N]: " confirm_choice
        if [[ ! "$confirm_choice" =~ ^[Yy]$ ]]; then
            echo "Deletion cancelled."
            exit 0
        fi

        read -rp "Type 'D' to confirm permanent deletion of '$del_dir': " confirm_delete
        if [[ "$confirm_delete" != "D" ]]; then
            echo "Deletion cancelled."
            exit 0
        fi

        if [[ "$current_target" == "$del_dir" ]]; then
            echo "Warning: removing symlink ctct_products as it points to the deleted volume."
            rm -f "$SYMLINK"
        fi

        echo "Deleting btrfs subvolume: $del_dir ..."
        btrfs subvolume delete "$SCRIPT_DIR/$del_dir"
        echo "Deleted: $del_dir"
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac

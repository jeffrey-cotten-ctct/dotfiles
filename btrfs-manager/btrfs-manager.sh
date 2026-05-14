#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYMLINK="$SCRIPT_DIR/ctct_products"

BLUE_BG=$'\e[44m'
WHITE_FG=$'\e[97m'
RESET=$'\e[0m'

# Display a numbered menu centered on screen with a blue background.
# Sets REPLY to the text of the selected option.
# Usage: styled_select "Title" "option1" "option2" ...
styled_select() {
    local title="$1"
    shift
    local -a options=("$@")
    local term_width
    term_width=$(tput cols 2>/dev/null || echo 80)

    local max_len=${#title}
    for i in "${!options[@]}"; do
        local entry="  $((i+1))) ${options[$i]}"
        (( ${#entry} > max_len )) && max_len=${#entry}
    done

    local box_width=$(( max_len + 4 ))
    local left_pad=$(( (term_width - box_width) / 2 ))
    (( left_pad < 0 )) && left_pad=0
    local pad
    pad=$(printf '%*s' "$left_pad" '')

    while true; do
        echo ""
        printf "%s${BLUE_BG}${WHITE_FG}  %-*s  ${RESET}\n" "$pad" "$max_len" "$title"
        for i in "${!options[@]}"; do
            printf "%s${BLUE_BG}${WHITE_FG}  %-*s  ${RESET}\n" "$pad" "$max_len" "  $((i+1))) ${options[$i]}"
        done
        echo ""

        read -rp "${pad}Enter choice [1-${#options[@]}]: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
            REPLY="${options[$((choice-1))]}"
            return 0
        fi
        echo "Invalid selection. Please try again."
    done
}

# Collect candidate directories (exclude the symlink itself)
mapfile -t dirs < <(find "$SCRIPT_DIR" -maxdepth 1 -mindepth 1 -type d ! -name "ctct_products" -printf "%f\n" | sort)

if [[ ${#dirs[@]} -eq 0 ]]; then
    echo "No directories found."
    exit 1
fi

current_target="$(readlink "$SYMLINK" 2>/dev/null || echo "(none)")"
echo "Current symlink: ctct_products -> $current_target"

styled_select "What would you like to do?" \
    "Switch btrfs symlink" \
    "Create a btrfs clone of a directory" \
    "Delete a btrfs volume" \
    "Check real space usage" \
    "List all snapshots"
main_choice="$REPLY"

case "$main_choice" in
    "Switch btrfs symlink")
        styled_select "Select a directory to switch to:" "${dirs[@]}"
        dir="$REPLY"
        ln -sfn "$dir" "$SYMLINK"
        echo "Updated: ctct_products -> $dir"
        ;;
    "Create a btrfs clone of a directory")
        styled_select "Select a directory to clone:" "${dirs[@]}"
        src_dir="$REPLY"

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
    "Delete a btrfs volume")
        styled_select "Select a volume to delete:" "${dirs[@]}"
        del_dir="$REPLY"

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
    "Check real space usage")
        echo ""
        echo "Btrfs filesystem usage for $SCRIPT_DIR:"
        echo ""
        btrfs filesystem usage "$SCRIPT_DIR"
        ;;
    "List all snapshots")
        echo ""
        echo "Btrfs subvolumes/snapshots under $SCRIPT_DIR:"
        echo ""
        btrfs subvolume list "$SCRIPT_DIR"
        ;;
esac

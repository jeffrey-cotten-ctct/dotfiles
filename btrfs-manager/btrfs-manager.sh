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

# After switching the symlink to a directory, check if its git branch matches the
# directory's ticket identifier and offer to checkout a matching branch if not.
# Usage: maybe_checkout_git_branch <dir_name>
maybe_checkout_git_branch() {
    local dir="$1"
    local new_dir_path="$SCRIPT_DIR/$dir"

    if git -C "$new_dir_path" rev-parse --is-inside-work-tree &>/dev/null; then
        current_branch=$(git -C "$new_dir_path" rev-parse --abbrev-ref HEAD 2>/dev/null || true)

        if [[ -n "$current_branch" ]]; then
            dir_ticket=""
            [[ "$dir" =~ ([A-Z]+-[0-9]+) ]] && dir_ticket="${BASH_REMATCH[1]}"

            branch_ticket=""
            [[ "$current_branch" =~ ([A-Z]+-[0-9]+) ]] && branch_ticket="${BASH_REMATCH[1]}"

            if [[ -n "$dir_ticket" && "$dir_ticket" == "$branch_ticket" ]]; then
                echo "Git branch: $current_branch"
            elif [[ -n "$dir_ticket" && "$dir_ticket" != "$branch_ticket" ]]; then
                echo "Git branch '$current_branch' does not match directory ticket '$dir_ticket'."

                mapfile -t matching_branches < <(
                    git -C "$new_dir_path" branch --all --format='%(refname:short)' \
                    | grep -i "$dir_ticket" \
                    | sed 's|^origin/||' \
                    | sort -u
                )

                if [[ ${#matching_branches[@]} -eq 0 ]]; then
                    echo "No git branches found matching '$dir_ticket'."
                elif [[ ${#matching_branches[@]} -eq 1 ]]; then
                    echo ""
                    read -rp "Checkout '${matching_branches[0]}'? [y/N]: " checkout_choice
                    if [[ "$checkout_choice" =~ ^[Yy]$ ]]; then
                        git -C "$new_dir_path" checkout "${matching_branches[0]}"
                    fi
                else
                    styled_select "Select a branch to checkout for '$dir_ticket':" "${matching_branches[@]}"
                    git -C "$new_dir_path" checkout "$REPLY"
                fi
            fi
        fi
    fi
}

to_human() {
    local b=$1
    if   (( b >= 1073741824 )); then awk "BEGIN {printf \"%.1f GiB\", $b/1073741824}"
    elif (( b >= 1048576    )); then awk "BEGIN {printf \"%.1f MiB\", $b/1048576}"
    elif (( b >= 1024       )); then awk "BEGIN {printf \"%.1f KiB\", $b/1024}"
    else echo "${b} B"; fi
}

print_space_usage() {
    local raw
    if ! raw=$(sudo -n btrfs filesystem usage -b "$SCRIPT_DIR" 2>/dev/null); then
        echo "  Sudo credentials are required to read btrfs space usage."
        if ! sudo -v; then
            echo "  Unable to acquire sudo credentials."
            echo ""
            return 0
        fi
        if ! raw=$(sudo btrfs filesystem usage -b "$SCRIPT_DIR" 2>/dev/null); then
            echo "  Unable to read btrfs space usage."
            echo ""
            return 0
        fi
    fi

    local total_b used_b free_b
    total_b=$(echo "$raw" | awk '/Device size:/       { print $NF }')
    used_b=$( echo "$raw" | awk '/^[[:space:]]+Used:/ { print $NF }')
    free_b=$(  echo "$raw" | awk '/Free \(estimated\):/ { print $3 }')

    local total_h used_h free_h pct
    total_h=$(to_human "$total_b")
    used_h=$( to_human "$used_b")
    free_h=$(  to_human "$free_b")
    pct=$(awk "BEGIN {printf \"%d\", ($used_b/$total_b)*100}")

    local bar_width=40
    local filled=$(( bar_width * pct / 100 ))
    local empty=$(( bar_width - filled ))
    local bar
    bar=$(printf '%*s' "$filled" '' | tr ' ' '█')$(printf '%*s' "$empty" '' | tr ' ' '░')

    echo "  Volume : $SCRIPT_DIR"
    echo ""
    printf "  Total  : %s\n"  "$total_h"
    printf "  Used   : %s\n"  "$used_h"
    printf "  Free   : %s\n"  "$free_h"
    echo ""
    printf "  [%s] %d%% used\n" "$bar" "$pct"
    echo ""

    if   (( pct >= 90 )); then echo "  ⚠️  WARNING: Volume is almost full! Consider resizing now."
    elif (( pct >= 75 )); then echo "  ⚠️  Volume is getting full. Consider resizing soon."
    fi
}

print_shared_space_savings() {
    local raw
    if ! raw=$(btrfs filesystem du -s --raw "$SCRIPT_DIR" 2>/dev/null); then
        if ! raw=$(sudo -n btrfs filesystem du -s --raw "$SCRIPT_DIR" 2>/dev/null); then
            echo "  Sudo credentials are required to read btrfs shared-space savings."
            if ! sudo -v; then
                echo "  Unable to acquire sudo credentials."
                echo ""
                return 0
            fi
            if ! raw=$(sudo btrfs filesystem du -s --raw "$SCRIPT_DIR" 2>/dev/null); then
                echo "  Unable to read btrfs shared-space savings."
                echo ""
                return 0
            fi
        fi
    fi

    local total_b exclusive_b set_shared_b
    read -r total_b exclusive_b set_shared_b < <(echo "$raw" | awk 'NR==2 {print $1, $2, $3}')

    if [[ -z "${total_b:-}" || -z "${exclusive_b:-}" || -z "${set_shared_b:-}" ]]; then
        echo "  Unexpected output from 'btrfs filesystem du'."
        echo ""
        return 0
    fi

    local savings_b=$(( total_b - exclusive_b ))
    local total_h exclusive_h set_shared_h savings_h
    total_h=$(to_human "$total_b")
    exclusive_h=$(to_human "$exclusive_b")
    set_shared_h=$(to_human "$set_shared_b")
    savings_h=$(to_human "$savings_b")

    local savings_pct=0
    if (( total_b > 0 )); then
        savings_pct=$(awk "BEGIN {printf \"%d\", ($savings_b/$total_b)*100}")
    fi

    echo "  Path      : $SCRIPT_DIR"
    echo ""
    printf "  Total     : %s (%s bytes)\n" "$total_h" "$total_b"
    printf "  Exclusive : %s (%s bytes)\n" "$exclusive_h" "$exclusive_b"
    printf "  Set shared: %s (%s bytes)\n" "$set_shared_h" "$set_shared_b"
    printf "  Savings   : %s (%s bytes, %d%%)\n" "$savings_h" "$savings_b" "$savings_pct"
    echo ""
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
    "Check btrfs shared-space savings" \
    "List all snapshots"
main_choice="$REPLY"

case "$main_choice" in
    "Switch btrfs symlink")
        styled_select "Select a directory to switch to:" "${dirs[@]}"
        dir="$REPLY"
        ln -sfn "$dir" "$SYMLINK"
        echo "Updated: ctct_products -> $dir"

        maybe_checkout_git_branch "$dir"
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
        sudo btrfs subvolume snapshot "$SCRIPT_DIR/$src_dir" "$clone_path"
        echo "Clone created: $clone_name"

        echo ""
        read -rp "Switch to '$clone_name' now? [y/N]: " switch_choice
        if [[ "$switch_choice" =~ ^[Yy]$ ]]; then
            ln -sfn "$clone_name" "$SYMLINK"
            echo "Updated: ctct_products -> $clone_name"
            maybe_checkout_git_branch "$clone_name"
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

        echo ""
        echo "--- Space usage before deletion ---"
        print_space_usage

        echo "Deleting btrfs subvolume: $del_dir ..."
        sudo btrfs subvolume delete "$SCRIPT_DIR/$del_dir"
        echo "Deleted: $del_dir"

        echo "Btrfs reclaim sync wait skipped."

        echo ""
        echo "Post-delete space usage check skipped."
        ;;
    "Check real space usage")
        echo ""
        print_space_usage
        ;;
    "Check btrfs shared-space savings")
        echo ""
        echo "  Calculating shared-space savings can take a moment. Please be patient..."
        echo ""
        print_shared_space_savings
        ;;
    "List all snapshots")
        echo ""
        echo "Btrfs subvolumes/snapshots under $SCRIPT_DIR:"
        echo ""
        sudo btrfs subvolume list "$SCRIPT_DIR"
        ;;
esac

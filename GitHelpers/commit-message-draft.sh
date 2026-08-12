#!/usr/bin/env bash
set -euo pipefail

# Drafts a commit message following git workflow rules.

branch="$(git branch --show-current 2>/dev/null || true)"
if [[ -z "${branch}" ]]; then
  echo "Error: not in a git repository or unable to determine current branch." >&2
  exit 1
fi

# Extract ticket prefix like ABC-123 from branch name.
if [[ "${branch}" =~ ([A-Z][A-Z0-9]+-[0-9]+) ]]; then
  ticket="${BASH_REMATCH[1]}"
else
  echo "Error: could not find ticket number in branch name '${branch}'." >&2
  echo "Expected something like: PPL-123-some-description" >&2
  exit 1
fi

types=(feat fix docs style refactor perf test chore ci revert)

echo "Detected ticket: ${ticket}"
echo "Select commit type:"
select type in "${types[@]}"; do
  if [[ -n "${type:-}" ]]; then
    break
  fi
  echo "Invalid selection, try again."
done

read -r -p "Scope (optional, e.g. mqtt): " scope
read -r -p "Description (imperative, lowercase, no period): " description

if [[ -z "${description}" ]]; then
  echo "Error: description is required." >&2
  exit 1
fi

read -r -p "Add body text? [y/N]: " add_body
body=""
if [[ "${add_body}" =~ ^[Yy]$ ]]; then
  echo "Enter body text. Finish with EOF (Ctrl-D):"
  body="$(cat || true)"
fi

if [[ -n "${scope}" ]]; then
  subject="${ticket}: ${type}(${scope}): ${description}"
else
  subject="${ticket}: ${type}: ${description}"
fi

echo
echo "----- Draft Commit Message -----"
echo "${subject}"
if [[ -n "${body}" ]]; then
  echo
  echo "${body}"
fi
echo "--------------------------------"
echo

tmp_file="$(mktemp /tmp/commit-msg.XXXXXX)"
{
  echo "${subject}"
  if [[ -n "${body}" ]]; then
    echo
    echo "${body}"
  fi
} > "${tmp_file}"

echo "Draft saved to: ${tmp_file}"
echo "Use it with: git commit -F ${tmp_file}"

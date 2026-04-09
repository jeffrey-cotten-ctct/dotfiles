# Dotfiles

Personal configuration files and preferences.

## Setup

This repository contains configuration files that are symlinked to their appropriate locations.

### Copilot Memory Files

The `copilot/` directory contains GitHub Copilot memory files that persist across workspaces:

```bash
# Symlink from VS Code Copilot memory location
~/.config/Code/User/globalStorage/github.copilot-chat/memory-tool/memories/git-workflow.md 
  -> ~/source/dotfiles/copilot/git-workflow.md
```

### Installation

To set up on a new machine:

```bash
# Clone this repository
git clone <your-repo-url> ~/source/dotfiles

# Create symlinks
ln -sf ~/source/dotfiles/copilot/git-workflow.md ~/.config/Code/User/globalStorage/github.copilot-chat/memory-tool/memories/git-workflow.md
```

## Contents

- `copilot/git-workflow.md` - Git commit message format rules (Conventional Commits with ticket numbers)

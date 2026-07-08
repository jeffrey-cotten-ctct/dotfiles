# Copilot Dotfiles

Personal GitHub Copilot instruction files that apply automatically to every VS Code Copilot session.

## Setup

Instructions files must be symlinked into VS Code's user prompts folder so they are picked up automatically.

### User prompts folder

```
~/.config/Code/User/prompts/
```

### Create symlinks

Run the following commands once on a new machine:

```bash
ln -s ~/source/dotfiles/copilot/git-workflow.instructions.md ~/.config/Code/User/prompts/git-workflow.instructions.md
ln -s ~/source/dotfiles/copilot/cpp.instructions.md ~/.config/Code/User/prompts/cpp.instructions.md
```

### How it works

Each `.instructions.md` file contains a YAML frontmatter block at the top:

```yaml
---
applyTo: "**"
---
```

The `applyTo: "**"` pattern tells VS Code Copilot to inject the instructions into every session automatically, without needing to reference them manually.

## Files

| File | Purpose |
|------|---------|
| `git-workflow.instructions.md` | Commit message format, PR template, log file conventions, and tool preferences |
| `cpp.instructions.md` | C++ language standard (C++17) applied to C/C++ source and header files |

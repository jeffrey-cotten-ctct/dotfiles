# Personal Git Workflow Rules

## Commit Message Format (Conventional Commits)

All my git commit messages MUST follow this format:

```
TICKET-XXX: type(scope): description

[optional body]

[optional footer(s)]
```

### Required Elements:
1. **Ticket number with colon**: `TICKET-XXX:` or `PROJ-123:` 
2. **Type**: One of the types below (required)
3. **Scope** (optional but recommended): Component/module affected
4. **Description**: Imperative mood, lowercase, no period at end

### Commit Types:
- **feat**: A new feature for the user
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Code style changes (formatting, missing semicolons, etc.) - no code behavior change
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Performance improvement
- **test**: Adding missing tests or correcting existing tests
- **chore**: Changes to build process, auxiliary tools, dependencies
- **ci**: Changes to CI configuration files and scripts
- **revert**: Reverts a previous commit

### Breaking Changes:
- Add `!` after type/scope: `PROJ-123: feat(api)!: change authentication flow`
- Or add `BREAKING CHANGE:` footer with description

### Description Guidelines:
- Use imperative, present tense: "change" not "changed" nor "changes"
- Don't capitalize first letter
- No period (.) at the end
- Describe what the commit does, not what you did

### Body (optional):
- Separated from description by blank line
- Can be multiple paragraphs
- Explain the motivation and contrast with previous behavior

### Footer (optional):
- One or more footers separated by blank lines
- Format: `<token>: <value>` or `BREAKING CHANGE: <description>`
- Common tokens: `Refs`, `Closes`, `Fixes`, `BREAKING CHANGE`

### Examples:
```
PPL-237: feat(mqtt): add typed DeviceStatus receiver
PPL-237: fix(gateway): resolve duplicate network info publications  
PPL-237: refactor(mp10xx): remove unused topicMatches helper
PROJ-456: docs(readme): update installation instructions
PROJ-456: perf(render): improve canvas draw by 50%

PPL-237: feat(api)!: remove deprecated authentication endpoints

The old /auth/v1 endpoints have been removed in favor of /auth/v2.
All clients must update to use the new OAuth2 flow.

BREAKING CHANGE: /auth/v1/* endpoints removed. Use /auth/v2/* instead.
Refs: #123, #456
```

## Git Tool Preferences

**NEVER use GitKraken MCP tools** (any tool starting with `mcp_gitkraken_`) - always use standard git commands via terminal instead.

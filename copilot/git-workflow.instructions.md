---
applyTo: "**"
---
# Personal Git Workflow Rules

## Commit Message Format (Conventional Commits)

All my git commit messages MUST follow this format:

```
TICKET-XXX: type(scope): description

[optional body]

[optional footer(s)]
```

### Finding the Ticket Number:
- The Jira ticket number can be found in the current git branch name (e.g. `PPL-123-some-description` → ticket is `PPL-123`)
- Run `git branch --show-current` to get the branch name if not already known

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

## Pull Request Description Template

When asked to generate a description for a PR, use the following template:

```
### Description

### Merge Checklist
- [ ] Automated tests run & showing no new failures
- [ ] Manual testing complete to the satisfaction of the team
- [ ] Any introduced issues that would block a release have been resolved
- [ ] Any identified regressions have been resolved

Refer to the [Tenzing Merge Process](https://ctctjv.atlassian.net/wiki/spaces/ctcteng/pages/90407328/Branching+and+Merging+Process) or talk to your team's Tenzing champion for more information

### Supporting Info
Insert links to information supporting this pull request
```

Always produce the output **twice**:
1. First, rendered normally (so it reads well in the chat).
2. Then, inside a fenced code block (` ```markdown `) containing the raw markdown — so it can be pasted directly into the GitHub/GitLab web portal.

## Log File Reference

When asked to "check logs" or "look at logs", always refer to:

```
~/Duplo/EarthworksData/SVR_LOG*.txt
```

**Important**: Log entry timestamps are in UTC. Local system time is NZST (UTC+12). To convert: `local time = log time + 12 hours`.

**Important**: The `Software Date` field in logs does **not** update for debug/local builds — ignore it when verifying which binary produced a given log. Use the binary file timestamp (`ls -lt .../Duplo`) instead.

## Committing

**ALWAYS show the proposed commit message and ask for confirmation before running `git commit`.**

When presenting a proposed commit message, always place the **entire** message (subject line, blank line, and body) inside a single fenced code block — never split the subject into one code block and the body into regular prose.

## Build Preferences

**NEVER run builds** — do not invoke build scripts (`build.sh`, `ctct_docker_runner`, etc.) on the user's behalf. Always let the user build themselves.

## Git Tool Preferences

**NEVER use GitKraken MCP tools** (any tool starting with `mcp_gitkraken_`) - always use standard git commands via terminal instead.

## Implementation Preferences

Please use existing helpers/utilities in this repo; avoid custom implementations unless none exist.

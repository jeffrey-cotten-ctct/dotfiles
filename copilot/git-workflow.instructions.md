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

### Review Spelling:
- When a word has inconsistent spellings in a review, prefer the New Zealand spelling.

## New Zealand Spelling Workflow

When editing prose in docs, markdown, comments, PR descriptions, review summaries, and chat responses:

- Default to New Zealand spelling.
- After content edits, run a short NZ spelling normalisation pass.
- Keep technical identifiers, code symbols, API names, branch names, and quoted text unchanged.
- Limit spelling passes to files changed in the current task unless I ask for a full-repo pass.
- Apply spelling-only edits during this pass (do not rewrite tone/wording unless asked).

Common variants to prefer in NZ style include:

- `behaviour` over `behavior`
- `organisation` over `organization`
- `optimise` over `optimize`
- `customise` over `customize`
- `initialise` over `initialize`
- `analyse` over `analyze`

If unsure whether a term is an identifier or prose, treat it as an identifier and do not change it.

### Body (optional):
- Separated from description by blank line
- Can be multiple paragraphs
- Explain the motivation and contrast with previous behaviour

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

## Pull Request Creation

When asked to create a PR (via `gh pr create` or similar), **always create it in Draft mode** by passing the `--draft` flag.

## Pull Request Description Template

When asked to draft/generate a PR (or a description for a PR), first ask me: "Would you like me to review your current git changes since you branched for bugs and code quality?" Only perform that review if I confirm.

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

## Peer Review Requirements for Unit Tests

When requesting a peer review, any unit tests that have been created or modified must include the following documentation:

### GIVEN WHEN THEN Sections
Above each test function, include a comment block describing the test structure:
```
// GIVEN: [initial state/preconditions]
// WHEN: [action being tested]
// THEN: [expected outcome/assertion]
```

### @test_purpose Tag
Each test must include a `@test_purpose` tag that briefly describes what the test validates. This tag should be placed in the test comment block or docstring, beneath the THEN line.

Example (for C++ tests):
```cpp
// GIVEN: A new DeviceManager instance
// WHEN: Instantiated without parameters
// THEN: All properties should have expected default values
// @test_purpose Verify that DeviceManager initialises with correct default values
TEST(DeviceManagerTest, InitialisesWithDefaults) {
  // test implementation
}
```

Example (for other languages):
```python
# GIVEN: A valid but soon-to-expire token (30 seconds to expiry)
# WHEN: The refresh endpoint is called
# THEN: A new valid token should be returned
# @test_purpose Verify authentication token refresh succeeds within expiry window
def test_token_refresh_within_window():
    # test implementation
```

### Include Path Review
When performing a peer review, examine all `#include` directives in changed files. If relative paths are used (e.g., `#include "../include/module.h"`), inform the user to avoid relative paths. Recommend using absolute paths from the project root or proper include directory configuration instead.

### Mosaic Message Receivers
When performing a peer review, if the changes involve Mosaic message receivers, note that the message and its payload cannot be null. Do not suggest gating null checks for either one.

### Recording Test Purposes

When creating or modifying unit tests as part of a peer review:

1. **For existing test files**: Check if there is already a corresponding `.md` documentation file (e.g., `TestDeviceManager-purposes.md` for `TestDeviceManager.cpp`). If it exists, add the test purpose to that existing document.

2. **For new test files**: 
   - You will be prompted to confirm the test file name
   - Copilot will suggest an appropriate location and filename for the documentation file (typically in a `Documentation` folder or alongside the test file)
   - The documentation should follow the same format as existing requirement/test purpose registries (see example below)

### Test Purpose Registry Format

Documentation files should follow this standardised table format with ID-based tracking:

```markdown
# Test Purposes for [Component/Module Name]

| ID | Test Name | Requirement (if applicable) | Description |
| --- | --- | --- | --- |
| TP.device.init.defaults | `InitialisesWithDefaults` | REQ.device.lifecycle | Verify that DeviceManager initialises with correct default values |
| TP.auth.token.refresh.valid | `test_token_refresh_within_window` | REQ.auth.token.expiry | Verify authentication token refresh succeeds within expiry window |
| TP.auth.login.attempt.tracking | `test_failed_login_increments_attempt_counter` | REQ.auth.security | Verify failed login attempts are tracked correctly |
```

The ID format follows the pattern: `TP.<module>.<component>.<scenario>` for consistency and traceability.

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

**NEVER include a `Co-authored-by` trailer** (e.g. `Co-authored-by: Copilot <...>`) in any commit message.

## Build Preferences

**NEVER run builds** — do not invoke build scripts (`build.sh`, `ctct_docker_runner`, etc.) on the user's behalf. Always let the user build themselves.

## Git Tool Preferences

**NEVER use GitKraken MCP tools** (any tool starting with `mcp_gitkraken_`) - always use standard git commands via terminal instead.

## Implementation Preferences

Please use existing helpers/utilities in this repo; avoid custom implementations unless none exist.

## Naming Conventions

- For new classes, do **not** use a `C` prefix (for example, prefer `DeviceManager` over `CDeviceManager`).
- Follow the existing project naming style for class names unless explicitly directed otherwise.

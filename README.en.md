# tmux-portal

A tmux plugin that streamlines session switching, new window creation, and command execution in a single workflow.

- Use case:
  - Manage AI agent sessions in dedicated tmux sessions for focused work

## Features

- **Session Switcher** - Quickly jump between tmux sessions
- **Current session excluded from switch candidates** - Only shows other sessions when switching
- **Session Auto-select** - No menu when there's only one option
- **Custom Status Styles** - Specify status line colors for visual differentiation
- **Command Integration** - Launch commands in new windows within specific sessions

## Installation

### tpm (recommended)

Add to your `~/.tmux.conf`:

```tmux
set -g @plugin 'zeero/tmux-portal'
```

Then press `prefix + I` to install.

### Manual Installation

```bash
git clone https://github.com/zeero/tmux-portal ~/.tmux/plugins/tmux-portal
```

Add to `~/.tmux.conf`:

```tmux
run-shell ~/.tmux/plugins/tmux-portal/portal.tmux
```

Reload tmux: `tmux source-file ~/.tmux.conf`

## Usage

| Option | Description |
|--------|-------------|
| `-s, --session <name>` | Session name (creates if missing) |
| `-c, --command <cmd>` | Command to run in new window |
| `--status-style <style>` | tmux status bar style (e.g., `fg=black,bg=yellow`) |
| `-h, --help` | Show help message |

### Switch between a dedicated AI agent session and regular sessions

```bash
tmux-portal -s claude -c claude --status-style "fg=black,bg=orange"

# Return to regular session
tmux-portal
```

### Basic Session Switching

```bash
# Show session switcher and jump to selected session
tmux-portal
```

Displays an interactive menu of all sessions except your current one. Select with numbers.

### Creating/Switching to Named Sessions

```bash
# Switch to (or create) a specific session
tmux-portal --session my-project
tmux-portal -s my-project
```

If the session doesn't exist, tmux-portal creates it before switching.

### Running Commands in Sessions

```bash
# Launch claude in a session after selecting from menu
tmux-portal --command claude

# Launch claude in a specific session
tmux-portal -s claude -c claude
```

Creates a new window in the target session and runs the command.

### Visual Differentiation with Status Styles

```bash
# Color-code your Claude session with yellow status bar
tmux-portal -s claude --status-style "fg=black,bg=yellow"

# Different color for Codex session
tmux-portal -s codex --status-style "fg=white,bg=blue"
```

Helps identify which AI agent you're working with at a glance.

## Example Workflow

```bash
# Set up color-coded sessions for different AI agents
tmux-portal -s claude -c claude --status-style "fg=black,bg=yellow"
tmux-portal -s codex -c codex --status-style "fg=white,bg=blue"
tmux-portal -s cursor -c cursor-agent --status-style "fg=black,bg=green"

# Later, quickly switch between them
tmux-portal  # Shows: codex, cursor (excludes current session)
```

## Requirements

- tmux
- Bash

## License

MIT License - see [LICENSE](LICENSE)

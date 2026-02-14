# tmux-portal

A tmux plugin designed to manage AI agent workflows in dedicated sessions and quickly switch between them and your regular development environment.

It streamlines session switching, new window creation, command execution, and status line customization into a single workflow.

## Features

- **Session Switcher** - Quickly select and switch from sessions other than the current one (auto-selects if only one candidate exists)
- **Command Integration** - Launch a command in a new window immediately upon switching sessions
- **Custom Status Styles** - Visually identify sessions by specifying status line colors

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

### Basic Usage
Display the session switcher and move to the selected session.

```bash
tmux-portal
```

Displays an interactive menu of all sessions except your current one. Select a session by its number.

#### Keybinding Example
Add the following to your `.tmux.conf` for quick access:

```tmux
bind-key C-p run-shell "tmux-portal"
```

### Switching to a Dedicated AI Agent Session
Create and switch to a session dedicated to an AI agent (e.g., Claude) and execute a command.

```bash
# Create/switch to "claude" session and run the "claude" command
tmux-portal -s claude -c claude --status-style "fg=black,bg=orange"

# Return to a regular session (select from the switcher)
tmux-portal
```

## Options
(New section - to be added in another issue)

## Requirements

- tmux
- Bash

## License

MIT License - see [LICENSE](LICENSE)

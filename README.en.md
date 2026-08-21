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

## Example Workflow

Gather your AI agents into an `agents` session, launch them in whatever directory you are working in, and return to your original session.

### 1. Register key bindings

Add the following to `~/.tmux.conf` and reload with `tmux source-file ~/.tmux.conf`.

```tmux
# Launch an agent
bind C-c run-shell "#{TMUX_PLUGIN_MANAGER_PATH}tmux-portal/scripts/tmux-portal.sh -s agents -c claude -p '✻ ' --status-style 'fg=black,bg=orange' --direnv"
bind C-f run-shell "#{TMUX_PLUGIN_MANAGER_PATH}tmux-portal/scripts/tmux-portal.sh -s agents -c 'claude --model fable' -p '🦋 ' --status-style 'fg=black,bg=orange' --direnv"
bind C-x run-shell "#{TMUX_PLUGIN_MANAGER_PATH}tmux-portal/scripts/tmux-portal.sh -s agents -c codex -p '❂ ' --status-style 'fg=black,bg=orange' --direnv"

# Move between sessions
bind W run-shell "#{TMUX_PLUGIN_MANAGER_PATH}tmux-portal/scripts/tmux-portal.sh"
```

tpm expands `#{TMUX_PLUGIN_MANAGER_PATH}` to the plugin directory. For a manual installation, use `~/.tmux/plugins/tmux-portal/scripts/tmux-portal.sh` instead.

Which agent a given window is running shows up as the badge added by `-p`.

### 2. Press `prefix + C-c` to launch Claude

Press it from the window where you are working in `myproject`.

- The `agents` session is created and you are switched to it
- A new window opens in the same directory as `myproject` and runs `claude`
- The window inherits the original window name and becomes `✻ myproject`
- The status bar turns orange, showing you are in the agent session

### 3. Press `prefix + C-x` to add Codex in the same directory

Press it while still in the `✻ myproject` window.

- A new window opens in the same `agents` session and the same directory, running `codex`
- The window name becomes `❂ myproject` — the `✻ ` badge is stripped, not stacked
- The Claude window stays open, so you can move between the two with tmux window switching

### 4. Press `prefix + W` to return to your original session

- Switches to a session other than `agents` (no menu appears when there is only one candidate)
- The agents keep running in the `agents` session
- Press `prefix + W` again to go back to `agents`

## Usage

| Option | Description |
|--------|-------------|
| `-s, --session <name>` | Session name (creates if missing) |
| `-c, --command <cmd>` | Command to run in new window |
| `--status-style <style>` | tmux status bar style (e.g., `fg=black,bg=yellow`) |
| `--window-status-current-style <style>` | Current tab style (defaults to swapped fg/bg from `--status-style`) |
| `-p, --window-prefix <str>` | Prefix for the new window name (any previously applied prefix is replaced) |
| `--direnv` | Load environment variables via `direnv exec` when running commands |
| `-h, --help` | Show help message |

### Switch between a dedicated AI agent session and regular sessions

```bash
tmux-portal -s agents -c claude --status-style "fg=black,bg=orange"

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
tmux-portal -s agents -c claude
```

Creates a new window in the target session and runs the command.

### Visual Differentiation with Status Styles

```bash
# Color-code your agent session with a yellow status bar
# → Current tab style is auto-set to fg=yellow,bg=black
tmux-portal -s agents --status-style "fg=black,bg=yellow"

# If you prefer one session per agent, give each session its own color
tmux-portal -s codex --status-style "fg=white,bg=blue"

# Explicitly specify the current tab style
tmux-portal -s aider --status-style "fg=black,bg=green" --window-status-current-style "fg=green,bg=black,bold"
```

Helps identify which AI agent you're working with at a glance.

When both `fg` and `bg` are specified in `--status-style`, the current tab (`window-status-current-style`) is automatically styled with swapped fg/bg. You can override this with `--window-status-current-style`.

> [!TIP]
> tmux defaults `status-left-length` to **10**, so session names may be truncated.
> Add the following to `~/.tmux.conf` to expand the display width:
>
> ```tmux
> set -g status-left-length 20
> ```

### Marking Windows with an Agent Badge

A new window inherits the name of the window you launched from. `-p` puts a badge in front of that name.

```bash
# Running from a window named "myproject" gives you "✻ myproject"
tmux-portal -s agents -c claude -p '✻ '

# Launching another agent from that window gives you "❂ myproject" (badges never stack)
tmux-portal -s agents -c codex -p '❂ '
```

The badge applied last is recorded in a tmux window option, so a badge left by a different command is stripped before the new one is added. Renaming the window by hand still works, as long as the badge remains at the front.

## Requirements

- tmux
- Bash

## License

MIT License - see [LICENSE](LICENSE)

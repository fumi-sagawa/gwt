# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Git Worktree Manager (gwt) is a command-line tool that simplifies Git worktree management. It's a shell script that provides an intuitive interface for creating, navigating, and managing Git worktrees using fzf for interactive selection.

## Key Commands

- **Testing the script**: Source the gwt.sh file in your current shell session
  ```bash
  source src/gwt.sh
  ```

- **Library installation (recommended)**: Install as a shell library
  ```bash
  ./src/install-lib.sh
  ```

- **Direct installation (legacy)**: Directly modify shell RC file
  ```bash
  ./src/install.sh
  ```

## Architecture

### Core Components

1. **src/gwt.sh** - Main shell function library
   - Auto-creates `.worktrees/` directory in project root
   - Manages `.gitignore` entries automatically
   - Provides commands: create, createfrom, goto, remove, list, help
   - Includes zsh/bash tab completion
   - Excludes already-used branches from createfrom selection
   - Single responsibility: create commands only create, navigation is separate

2. **src/install-lib.sh** - Library installation script (recommended)
   - Installs gwt as a library to `~/.config/gwt/`
   - Adds only one line to shell RC file
   - Clean and minimal shell configuration
   - Easy updates and uninstalls

3. **src/install.sh** - Direct installation script (legacy)
   - Detects shell type (bash/zsh)
   - Checks dependencies (git, fzf)
   - Appends gwt.sh content directly to shell RC file
   - Creates backups before modification

4. **src/uninstall.sh** - Uninstallation script
   - Safely removes gwt from shell configuration
   - Creates backup before modification
   - Provides clear instructions

### Function Architecture

The `gwt()` function uses a case statement to handle subcommands:
- `create <name>`: Creates worktree at `.worktrees/<name>` with new branch (creation only)
- `createfrom [branch]`: Creates worktree from existing branch (local or remote), supports fzf selection when no branch specified, excludes already-used branches
- `goto`: Interactive worktree navigation using fzf
- `remove`: Interactive worktree removal using fzf
- `list`: Lists all worktrees with visual indicators
- `help`: Shows usage information

### Directory Structure

```
gwt/
├── src/                    # Source code files
│   ├── gwt.sh             # Main gwt library
│   ├── install-lib.sh     # Library installation script
│   ├── uninstall-lib.sh   # Library uninstallation script
│   ├── install.sh         # Direct installation script
│   ├── uninstall.sh       # Direct uninstallation script
│   └── test_*.sh          # Test scripts
├── docs/                   # Documentation
│   ├── usage.md           # Detailed usage guide
│   └── troubleshooting.md # Troubleshooting guide
├── _tickets/              # Task management
│   ├── 00_todo/          # Pending tasks
│   ├── 01_doing/         # Tasks in progress
│   └── 02_done/          # Completed tasks
├── README.md             # Japanese documentation
├── README_EN.md          # English documentation
├── CHANGELOG.md          # Version history
└── CLAUDE.md            # This file

### Library Structure

When installed as a library:
```
~/.config/gwt/
└── gwt.sh                # gwt library file

~/.zshrc or ~/.bashrc
└── [[ -f ~/.config/gwt/gwt.sh ]] && source ~/.config/gwt/gwt.sh
```

Worktrees are stored in `.worktrees/` subdirectory of the Git repository root. The tool automatically:
- Creates this directory on first use
- Adds it to `.gitignore`
- Uses project root detection via `git rev-parse --show-toplevel`

## Development Notes

- The script is POSIX-compliant bash/zsh
- Uses fzf for interactive selection (required dependency)
- Supports both bash 4.0+ and zsh 5.0+
- Tab completion is implemented via `_gwt_completion` function
- Supports existing branches (local and remote)
- Enhanced error handling with helpful messages

## Ticket Management System

### チケット管理ルール

プロジェクトの改善提案や作業項目は `_tickets/` ディレクトリで管理します：

- `_tickets/todo/` - 未着手のチケット
- `_tickets/doing/` - 作業中のチケット  
- `_tickets/done/` - 完了したチケット

### ワークフロー

1. 新しい提案や作業項目は `_tickets/todo/` にMarkdownファイルとして作成
2. 作業開始時は該当ファイルを `_tickets/doing/` に移動
3. 作業完了時は `_tickets/done/` に移動

### ファイル命名規則

`YYYYMMDD-<カテゴリ>-<簡潔な説明>.md`

例: `20250619-feature-existing-branch-support.md`
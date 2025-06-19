# Git Worktree Manager (gwt) 🌲

<div align="center">

[![Shell: Bash/Zsh](https://img.shields.io/badge/Shell-Bash%2FZsh-green.svg)](https://www.gnu.org/software/bash/)
[![Dependencies: fzf](https://img.shields.io/badge/Dependencies-fzf-blue.svg)](https://github.com/junegunn/fzf)

**A simple and powerful tool to manage Git worktrees efficiently**

English | [日本語](README.md)

</div>

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Demo](#-demo)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Usage](#-usage)
- [Configuration](#-configuration)
- [Troubleshooting](#-troubleshooting)

## 🎯 Overview

Git Worktree Manager (gwt) is a command-line tool that makes Git's worktree feature more accessible and user-friendly. It speeds up context switching between multiple branches and improves development efficiency.

### Why use gwt?

- **Fast context switching**: Switch between branches instantly without `git stash` or `git checkout`
- **Parallel development**: Work on multiple features or bug fixes simultaneously
- **Clean working environment**: Each branch has its own directory, no build cache conflicts
- **Intuitive interface**: Interactive selection using fzf

## ✨ Features

- 🚀 **Simple commands**: `gwt create`, `gwt createfrom`, `gwt goto`, `gwt remove`, `gwt list`
- 🔍 **fzf integration**: Quick and intuitive worktree selection
- 📁 **Automatic directory management**: Auto-creates and manages `.worktrees/` directory
- 🎨 **Visual list display**: Clear indication of current worktree
- 🔧 **Tab completion support**: Auto-completion for zsh/bash
- 🏠 **Project root aware**: Access any worktree from any location

## 🎬 Demo

```bash
# Create a new feature branch
$ gwt create feature-auth
Creating new branch: feature-auth
✅ Worktree created successfully: feature-auth
📍 Location: /path/to/project/.worktrees/feature-auth

To navigate to the worktree: gwt goto

# Create from existing branch (with fzf selection)
$ gwt createfrom
┌─────────────────────────────────┐
│ Select branch (excluding worktrees): │
├─────────────────────────────────┤
│ > main                          │
│   develop                       │
│   origin/feature-x              │
└─────────────────────────────────┘

# Navigate between worktrees
$ gwt goto
┌─────────────────────────────────┐
│ Select worktree:                │
├─────────────────────────────────┤
│ > [main] .                      │
│   [feature-auth] feature-auth   │
│   [bugfix-login] bugfix-login   │
└─────────────────────────────────┘

# Check current status
$ gwt list
🏠 Project: my-app

   . (root) [main]
📍 feature-auth [feature-auth]
   bugfix-login [bugfix-login]
```

## 📦 Requirements

- Git 2.5 or higher
- Bash 4.0+ or Zsh 5.0+
- [fzf](https://github.com/junegunn/fzf) (fuzzy finder)

### Installing fzf

```bash
# macOS
brew install fzf

# Ubuntu/Debian
sudo apt install fzf

# Arch Linux
sudo pacman -S fzf

# Other OS
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

## 🚀 Installation

### Method 1: Library Installation (Recommended)

Clean installation that adds only one line to your .zshrc/.bashrc:

```bash
# Clone the repository
git clone https://github.com/yourusername/gwt.git
cd gwt

# Run the library installation script
./src/install-lib.sh
```

**What it does**:
- Installs gwt library to `~/.config/gwt/gwt.sh`
- Adds only one line to your shell RC file:
  ```bash
  [[ -f ~/.config/gwt/gwt.sh ]] && source ~/.config/gwt/gwt.sh
  ```

### Method 2: Direct Shell RC Modification

If you prefer to directly modify your .zshrc/.bashrc, use the traditional installation:

```bash
./src/install.sh  # Appends gwt.sh content directly to .zshrc
```

### Method 3: Manual Installation

1. **Copy gwt.sh to your preferred location**
```bash
cp src/gwt.sh ~/.config/gwt/
```

2. **Add source line to .zshrc or .bashrc**
```bash
echo '[[ -f ~/.config/gwt/gwt.sh ]] && source ~/.config/gwt/gwt.sh' >> ~/.zshrc
```

3. **Reload your shell configuration**
```bash
source ~/.zshrc  # for zsh
source ~/.bashrc  # for bash
```

That's it! Installation is complete.

**Note**: gwt automatically handles the following on first use:
- Creates the `.worktrees` directory
- Adds `.worktrees/` to `.gitignore` (if not already present)

### Uninstallation

```bash
# For library installation
rm -rf ~/.config/gwt
# Then remove the gwt line from .zshrc

# For direct installation
./src/uninstall.sh
```

## 📖 Usage

### Basic Commands

| Command | Description |
|---------|-------------|
| `gwt create <name>` | Create new worktree with a new branch |
| `gwt createfrom [branch]` | Create new worktree from existing branch (supports fzf selection) |
| `gwt goto` | Select and navigate to worktree (uses fzf) |
| `gwt remove` | Select and remove worktree (uses fzf) |
| `gwt list` | List all worktrees |
| `gwt help` | Show help message |

### Typical Workflow

```bash
# 1. Navigate to project
cd ~/projects/my-app

# 2. Start working on a new feature
gwt create feature-payment

# 3. Development work...
echo "// Payment logic" >> payment.js
git add payment.js
git commit -m "feat: Add payment processing"

# 4. Urgent bug fix needed
gwt create hotfix-security

# 5. Fix the bug...
vim security.js
git add security.js
git commit -m "fix: Security vulnerability"
git push origin hotfix-security

# 6. Return to original work
gwt goto  # Select feature-payment

# 7. Clean up after work is done
gwt remove  # Select hotfix-security
```

### Parallel Development Example

Working on different tasks simultaneously in 3 terminals:

```bash
# Terminal 1: API development
gwt create feature-api
npm run dev

# Terminal 2: UI testing
gwt create feature-ui
npm run test:watch

# Terminal 3: Documentation updates
gwt goto  # Select main
npm run docs:serve
```

## ⚙️ Configuration

### Environment Variables

```bash
# Change default worktree directory
export GWT_WORKTREE_DIR=".branches"  # Default is .worktrees

# Customize fzf options
export FZF_DEFAULT_OPTS='--height 50% --layout=reverse --border'
```

### Aliases

Set up shortcuts for frequently used commands:

```bash
# Add to ~/.zshrc or ~/.bashrc
alias gwc='gwt create'
alias gwcf='gwt createfrom'
alias gwg='gwt goto'
alias gwr='gwt remove'
alias gwl='gwt list'
```

### Per-Project Configuration

Create `.gwtrc` in project root:

```bash
# .gwtrc
GWT_WORKTREE_DIR=".branches"
GWT_DEFAULT_BRANCH="develop"
```

## 🔧 Troubleshooting

### Common Issues and Solutions

<details>
<summary><strong>gwt: command not found</strong></summary>

Your shell configuration file might not be loaded properly:

```bash
# Check your current shell
echo $SHELL

# Reload configuration
source ~/.zshrc  # for zsh
source ~/.bashrc  # for bash
```
</details>

<details>
<summary><strong>fzf: command not found</strong></summary>

fzf is not installed:

```bash
# Check installation
which fzf

# Install fzf
brew install fzf  # macOS
sudo apt install fzf  # Ubuntu/Debian
```
</details>

<details>
<summary><strong>Cannot remove worktree</strong></summary>

The worktree might be locked or have uncommitted changes:

```bash
# Force remove
git worktree remove --force .worktrees/branch-name

# If that doesn't work
rm -rf .worktrees/branch-name
git worktree prune
```
</details>

For detailed troubleshooting, see [troubleshooting guide](docs/troubleshooting.md).


## 🙏 Acknowledgments

- [fzf](https://github.com/junegunn/fzf) - An amazing fuzzy finder
- The developers of Git worktree feature
- All contributors to this project

---

<div align="center">

**[⬆ Back to top](#git-worktree-manager-gwt-)**

Made with ❤️ by the gwt community

</div>
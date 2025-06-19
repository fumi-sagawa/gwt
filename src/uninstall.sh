#!/usr/bin/env bash

# Git Worktree Manager (gwt) - Uninstall Script

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC}  $1"
}

# Main uninstall function
main() {
    echo "Git Worktree Manager (gwt) - Uninstall"
    echo "======================================"
    echo ""
    
    print_warning "This will remove gwt from your system."
    echo ""
    
    # Check shell
    local shell_rc=""
    local shell_name=""
    local user_shell=$(basename "$SHELL")
    
    if [[ "$user_shell" == "zsh" ]]; then
        shell_rc="$HOME/.zshrc"
        shell_name="zsh"
    elif [[ "$user_shell" == "bash" ]]; then
        shell_rc="$HOME/.bashrc"
        shell_name="bash"
    else
        print_error "Unsupported shell: $user_shell. Please manually remove gwt from your shell configuration."
        exit 1
    fi
    
    echo "Detected shell: $shell_name"
    echo "Configuration file: $shell_rc"
    echo ""
    
    # Check if gwt is installed
    if ! grep -q "Git Worktree Manager (gwt)" "$shell_rc" 2>/dev/null; then
        print_info "gwt does not appear to be installed in $shell_rc"
        echo ""
        echo "If gwt is installed elsewhere, please remove it manually."
        exit 0
    fi
    
    echo "This will:"
    echo "  • Remove gwt from $shell_rc"
    echo "  • Create a backup at $shell_rc.gwt-backup"
    echo ""
    echo "Note: This will NOT remove worktrees in your projects."
    echo "      To clean up worktrees, run 'git worktree prune' in each project."
    echo ""
    
    read -p "Continue with uninstall? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "Uninstall cancelled."
        exit 0
    fi
    
    echo ""
    print_info "Uninstalling gwt..."
    echo ""
    
    # Create backup
    if cp "$shell_rc" "$shell_rc.gwt-backup"; then
        print_success "Created backup: $shell_rc.gwt-backup"
    else
        print_error "Failed to create backup"
        exit 1
    fi
    
    # Remove gwt from shell configuration
    if sed -i.tmp '/# Git Worktree Manager (gwt)/,/compdef _gwt_completion gwt/d' "$shell_rc"; then
        rm -f "$shell_rc.tmp"
        print_success "Removed gwt from $shell_rc"
    else
        print_error "Failed to remove gwt from $shell_rc"
        echo "Please check the backup and manually edit $shell_rc if needed."
        exit 1
    fi
    
    echo ""
    print_success "gwt has been uninstalled!"
    echo ""
    echo "To complete the uninstall:"
    echo "  source $shell_rc"
    echo ""
    echo "To reinstall gwt later:"
    echo "  ./install.sh"
    echo ""
    echo "To clean up worktrees in a project:"
    echo "  cd /path/to/project"
    echo "  git worktree list"
    echo "  git worktree remove <worktree-path>"
    echo ""
    echo "Thank you for using gwt! 👋"
}

# Run main
main
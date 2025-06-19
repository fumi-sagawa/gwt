#!/usr/bin/env bash

# Git Worktree Manager (gwt) - Library Uninstallation Script

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
GWT_HOME="$HOME/.config/gwt"
GWT_LIB="$GWT_HOME/gwt.sh"

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

print_code() {
    echo -e "${BLUE}$1${NC}"
}

# Check if running on supported shell
check_shell() {
    # Check user's default shell instead of current shell
    local user_shell=$(basename "$SHELL")
    
    if [[ "$user_shell" == "zsh" ]]; then
        SHELL_RC="$HOME/.zshrc"
        SHELL_NAME="zsh"
        return 0
    elif [[ "$user_shell" == "bash" ]]; then
        SHELL_RC="$HOME/.bashrc"
        SHELL_NAME="bash"
        return 0
    else
        print_error "Unsupported shell: $user_shell. Please use bash or zsh."
        return 1
    fi
}

# Uninstall gwt library
uninstall_gwt_library() {
    print_info "Uninstalling Git Worktree Manager (gwt) library..."
    
    # Remove gwt directory
    if [[ -d "$GWT_HOME" ]]; then
        rm -rf "$GWT_HOME"
        print_success "Removed gwt library directory: $GWT_HOME"
    else
        print_info "gwt library directory not found: $GWT_HOME"
    fi
    
    # Check if source line exists in shell rc
    if grep -q "$GWT_LIB" "$SHELL_RC" 2>/dev/null; then
        # Create backup
        cp "$SHELL_RC" "$SHELL_RC.backup.$(date +%Y%m%d_%H%M%S)"
        print_success "Created backup: $SHELL_RC.backup.*"
        
        # Remove gwt lines from shell rc
        # Remove the gwt comment line and source line
        sed -i.tmp '/# Git Worktree Manager (gwt)/d' "$SHELL_RC"
        sed -i.tmp "\|$GWT_LIB|d" "$SHELL_RC"
        rm -f "$SHELL_RC.tmp"
        
        print_success "Removed gwt source line from $SHELL_RC"
    else
        print_info "No gwt configuration found in $SHELL_RC"
    fi
    
    return 0
}

# Main uninstallation
main() {
    echo "Git Worktree Manager (gwt) - Library Uninstallation"
    echo "==================================================="
    echo ""
    
    # Check shell
    if ! check_shell; then
        exit 1
    fi
    
    print_info "This will remove gwt library installation"
    echo ""
    
    read -p "Are you sure you want to uninstall gwt? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Uninstallation cancelled."
        exit 0
    fi
    
    echo ""
    
    # Uninstall
    if uninstall_gwt_library; then
        echo ""
        print_success "Uninstallation completed!"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "gwt has been uninstalled."
        echo ""
        echo "To complete the uninstallation:"
        echo "  1. Reload your shell configuration:"
        print_code "     source $SHELL_RC"
        echo ""
        echo "  2. Or start a new terminal session"
        echo ""
        echo "Thank you for using gwt! 👋"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    else
        print_error "Uninstallation failed"
        exit 1
    fi
}

# Run main
main
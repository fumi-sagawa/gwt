#!/usr/bin/env bash

# Git Worktree Manager (gwt) - Installation Script

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

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    if ! command -v fzf &> /dev/null; then
        missing_deps+=("fzf")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        echo ""
        echo "Please install missing dependencies:"
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "  brew install ${missing_deps[*]}"
        elif [[ -f /etc/debian_version ]]; then
            echo "  sudo apt install ${missing_deps[*]}"
        elif [[ -f /etc/arch-release ]]; then
            echo "  sudo pacman -S ${missing_deps[*]}"
        else
            echo "  Please install: ${missing_deps[*]}"
        fi
        
        return 1
    fi
    
    print_success "All dependencies are installed"
    return 0
}

# Install gwt
install_gwt() {
    print_info "Installing Git Worktree Manager (gwt)..."
    
    # Create backup if shell rc exists
    if [[ -f "$SHELL_RC" ]]; then
        cp "$SHELL_RC" "$SHELL_RC.backup.$(date +%Y%m%d_%H%M%S)"
        print_success "Created backup: $SHELL_RC.backup.*"
    fi
    
    # Check if gwt is already installed
    if grep -q "Git Worktree Manager (gwt)" "$SHELL_RC" 2>/dev/null; then
        print_info "gwt appears to be already installed. Updating..."
        # Remove old installation
        sed -i.tmp '/# Git Worktree Manager (gwt)/,/compdef _gwt_completion gwt/d' "$SHELL_RC"
        rm -f "$SHELL_RC.tmp"
    fi
    
    # Add gwt to shell rc
    echo "" >> "$SHELL_RC"
    cat "$(dirname "$0")/gwt.sh" >> "$SHELL_RC"
    
    print_success "Added gwt to $SHELL_RC"
    
    # Note about gitignore
    print_info "Note: When using gwt in a project, add '.worktrees/' to that project's .gitignore file"
    
    return 0
}

# Main installation
main() {
    echo "Git Worktree Manager (gwt) - Installation"
    echo "========================================="
    echo ""
    echo "⚠️  This installation method directly modifies your shell RC file."
    echo "   For a cleaner installation, use install-lib.sh instead:"
    echo ""
    echo "   ./src/install-lib.sh"
    echo ""
    read -p "Continue with direct installation? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    echo ""
    
    # Check shell
    if ! check_shell; then
        exit 1
    fi
    
    print_success "Detected shell: $SHELL_NAME"
    echo ""
    
    # Check dependencies
    if ! check_dependencies; then
        exit 1
    fi
    
    echo ""
    
    # Install
    if install_gwt; then
        echo ""
        print_success "Installation completed!"
        echo ""
        echo "Next steps:"
        echo "1. Reload your shell configuration:"
        echo "   source $SHELL_RC"
        echo ""
        echo "2. Try gwt:"
        echo "   gwt help"
        echo ""
        echo "Happy coding! 🚀"
    else
        print_error "Installation failed"
        exit 1
    fi
}

# Run main
main
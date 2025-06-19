#!/usr/bin/env bash

# Git Worktree Manager (gwt) - Library Installation Script

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

# Install gwt library
install_gwt_library() {
    print_info "Installing Git Worktree Manager (gwt) as a library..."
    
    # Create config directory
    mkdir -p "$GWT_HOME"
    print_success "Created directory: $GWT_HOME"
    
    # Copy gwt.sh to config directory
    cp "$(dirname "$0")/gwt.sh" "$GWT_LIB"
    print_success "Installed gwt library to: $GWT_LIB"
    
    # Check if source line already exists in shell rc
    local source_line="[[ -f $GWT_LIB ]] && source $GWT_LIB"
    
    if grep -q "$GWT_LIB" "$SHELL_RC" 2>/dev/null; then
        print_info "gwt is already configured in $SHELL_RC"
    else
        # Create backup
        cp "$SHELL_RC" "$SHELL_RC.backup.$(date +%Y%m%d_%H%M%S)"
        print_success "Created backup: $SHELL_RC.backup.*"
        
        # Add source line to shell rc
        echo "" >> "$SHELL_RC"
        echo "# Git Worktree Manager (gwt)" >> "$SHELL_RC"
        echo "$source_line" >> "$SHELL_RC"
        
        print_success "Added gwt source line to $SHELL_RC"
    fi
    
    return 0
}

# Main installation
main() {
    echo "Git Worktree Manager (gwt) - Library Installation"
    echo "================================================="
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
    if install_gwt_library; then
        echo ""
        print_success "Installation completed!"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "🎉 gwt has been installed as a shell library!"
        echo ""
        echo "Installation details:"
        echo "  • Library location: $GWT_LIB"
        echo "  • Shell config: $SHELL_RC"
        echo "  • Added line: ${source_line}"
        echo ""
        echo "Next steps:"
        echo "  1. Reload your shell configuration:"
        print_code "     source $SHELL_RC"
        echo ""
        echo "  2. Try gwt:"
        print_code "     gwt help"
        echo ""
        echo "To update gwt in the future:"
        print_code "  cd /path/to/gwt && ./src/install-lib.sh"
        echo ""
        echo "To uninstall gwt:"
        print_code "  rm -rf $GWT_HOME"
        print_code "  # Then remove the gwt line from $SHELL_RC"
        echo ""
        echo "Happy coding! 🚀"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    else
        print_error "Installation failed"
        exit 1
    fi
}

# Run main
main
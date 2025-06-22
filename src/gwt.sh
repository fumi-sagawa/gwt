#!/usr/bin/env bash

# Git Worktree Manager (gwt)
# A simple and efficient tool for managing git worktrees

# Constants (avoid readonly for re-sourcing compatibility)
GWT_WORKTREE_DIR=".worktrees"
GWT_DEFAULT_BRANCH="main"

# Helper functions
_gwt_error() {
    echo "❌ Error: $1"
    [[ -n "$2" ]] && echo "$2"
    return 1
}

_gwt_check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        _gwt_error "Not in a git repository!" \
            "\nRun 'git init' or navigate to a git repository."
        return 1
    fi
    return 0
}

_gwt_check_initial_commit() {
    if ! git rev-parse HEAD > /dev/null 2>&1; then
        _gwt_error "No commits found!" \
            "\nMake at least one commit:\n  $ git add .\n  $ git commit -m \"Initial commit\""
        return 1
    fi
    return 0
}

_gwt_get_root_dir() {
    # git worktree list outputs: <path> <commit> [<branch>]
    # Use sed to extract path more safely (handles spaces in paths)
    git worktree list | head -1 | sed -E 's/^([^ ]+|"[^"]+").*$/\1/' | tr -d '"'
}

_gwt_worktree_path() {
    echo "$1/$GWT_WORKTREE_DIR/$2"
}

_gwt_setup_worktree_dir() {
    local root_dir="$1"
    
    if [[ ! -d "$root_dir/$GWT_WORKTREE_DIR" ]]; then
        mkdir -p "$root_dir/$GWT_WORKTREE_DIR"
        
        # Add to .gitignore if not already present
        if [[ -f "$root_dir/.gitignore" ]]; then
            if ! grep -q "^$GWT_WORKTREE_DIR/$" "$root_dir/.gitignore" 2>/dev/null; then
                echo "" >> "$root_dir/.gitignore"
                echo "# Git worktrees" >> "$root_dir/.gitignore"
                echo "$GWT_WORKTREE_DIR/" >> "$root_dir/.gitignore"
                echo "Added $GWT_WORKTREE_DIR/ to .gitignore"
            fi
        else
            echo "# Git worktrees" > "$root_dir/.gitignore"
            echo "$GWT_WORKTREE_DIR/" >> "$root_dir/.gitignore"
            echo "Created .gitignore with $GWT_WORKTREE_DIR/ entry"
        fi
    fi
}

_gwt_create_worktree_error() {
    _gwt_error "Failed to create worktree!" \
        "\nPossible reasons:\n  - Branch/worktree already exists\n  - Invalid branch name\n  - Disk space or permission issues\n\nUse 'gwt list' to see existing worktrees"
}

_gwt_get_worktree_list() {
    local root_dir="$1"
    local root_branch="$2"
    local options="[${root_branch:-$GWT_DEFAULT_BRANCH}] .\n"
    
    if [[ -d "$root_dir/$GWT_WORKTREE_DIR" ]]; then
        for dir in "$root_dir"/$GWT_WORKTREE_DIR/*/; do
            if [[ -d "$dir" ]]; then
                local branch=$(git -C "$dir" branch --show-current 2>/dev/null)
                options+="[$branch] $(basename "$dir")\n"
            fi
        done 2>/dev/null
    fi
    
    printf "%b" "$options"
}

_gwt_get_used_branches() {
    # Get all branches currently used by worktrees
    git worktree list --porcelain | grep '^branch ' | sed 's/^branch refs\/heads\///'
}

_gwt_change_to_worktree() {
    local root_dir="$1"
    local selected="$2"
    local root_branch="$3"
    
    if [[ "$selected" == "." ]]; then
        echo "📍 Switching to: root [${root_branch:-$GWT_DEFAULT_BRANCH}]"
        if cd "$root_dir" 2>/dev/null; then
            echo "✅ Current directory: $(pwd)"
        else
            _gwt_error "Failed to change directory to: $root_dir"
            return 1
        fi
    else
        local target_dir=$(_gwt_worktree_path "$root_dir" "$selected")
        echo "📍 Switching to: $selected"
        if [[ -d "$target_dir" ]]; then
            if cd "$target_dir" 2>/dev/null; then
                local new_branch=$(git branch --show-current 2>/dev/null)
                echo "✅ Current directory: $(pwd)"
                echo "📍 Branch: [$new_branch]"
            else
                _gwt_error "Failed to change directory to: $target_dir"
                return 1
            fi
        else
            _gwt_error "Directory does not exist: $target_dir"
            return 1
        fi
    fi
}

_gwt_list_worktrees() {
    local root_dir="$1"
    local root_branch="$2"
    local current_dir=$(pwd -P)
    
    echo "🏠 Project: $(basename "$root_dir")"
    echo ""
    
    # Root directory
    local root_path=$(cd "$root_dir" && pwd -P 2>/dev/null || echo "$root_dir")
    local marker=$([[ "$current_dir" == "$root_path" ]] && echo "📍" || echo "  ")
    echo "$marker . (root) [${root_branch:-$GWT_DEFAULT_BRANCH}]"
    
    # Worktrees
    if [[ -d "$root_dir/$GWT_WORKTREE_DIR" ]]; then
        for dir in "$root_dir"/$GWT_WORKTREE_DIR/*/; do
            if [[ -d "$dir" ]]; then
                local branch=$(git -C "$dir" branch --show-current 2>/dev/null)
                local dirname=$(basename "$dir")
                local worktree_path=$(cd "$dir" && pwd -P 2>/dev/null || echo "$dir")
                local marker=$([[ "$current_dir" == "$worktree_path" ]] && echo "📍" || echo "  ")
                echo "$marker $dirname [$branch]"
            fi
        done 2>/dev/null
    fi
}

gwt() {
    # Check if in git repository
    _gwt_check_git_repo || return 1
    
    # Get project root directory
    local root_dir=$(_gwt_get_root_dir)
    if [[ -z "$root_dir" ]]; then
        _gwt_error "Could not find git repository root"
        return 1
    fi
    
    # Get root branch name
    local root_branch=""
    if [[ -d "$root_dir/.git" ]]; then
        root_branch=$(git -C "$root_dir" branch --show-current 2>/dev/null)
    fi
    
    # Setup worktree directory
    _gwt_setup_worktree_dir "$root_dir"
    
    case "$1" in
        create)
            if [[ -z "$2" ]]; then
                _gwt_error "Branch name required!" "\nUsage: gwt create <branch-name>\nExample: gwt create feature-auth"
                return 1
            fi
            
            _gwt_check_initial_commit || return 1
            
            local worktree_path=$(_gwt_worktree_path "$root_dir" "$2")
            echo "Creating new branch: $2"
            
            if git worktree add "$worktree_path" -b "$2"; then
                echo "✅ Worktree created successfully: $2"
                echo "📍 Location: $worktree_path"
                echo ""
                echo "To navigate to the worktree: gwt goto"
            else
                _gwt_create_worktree_error
                return 1
            fi
            ;;
            
        createfrom)
            _gwt_check_initial_commit || return 1
            
            local branch_name="$2"
            
            # If no branch name provided, use fzf for interactive selection
            if [[ -z "$branch_name" ]]; then
                # Get branches currently used by worktrees
                local used_branches=$(_gwt_get_used_branches)
                
                # Get all branches (local and remote), remove duplicates and exclude used branches
                local branches=$(git branch -a | \
                    sed 's/^[*+ ] //' | \
                    sed 's/^remotes\/origin\///' | \
                    grep -v 'HEAD ->' | \
                    sort -u | \
                    grep -v -F -x -f <(echo "$used_branches"))
                
                if [[ -z "$branches" ]]; then
                    _gwt_error "No available branches found!" \
                        "\nAll branches are already in use as worktrees.\nCreate a new branch with: gwt create <branch-name>"
                    return 1
                fi
                
                branch_name=$(echo "$branches" | fzf --height 40% --reverse --prompt="Select branch (excluding worktrees): ")
                
                if [[ -z "$branch_name" ]]; then
                    echo "ℹ️  No branch selected."
                    return 0
                fi
            fi
            
            # Check if branch is already used by a worktree
            local used_branches=$(_gwt_get_used_branches)
            if echo "$used_branches" | grep -q -F -x "$branch_name"; then
                _gwt_error "Branch '$branch_name' is already in use as a worktree!" \
                    "\nUse 'gwt goto' to navigate to existing worktrees.\nUse 'gwt list' to see all worktrees."
                return 1
            fi
            
            local worktree_path=$(_gwt_worktree_path "$root_dir" "$branch_name")
            
            # Check if branch exists (local or remote)
            if git show-ref --verify --quiet "refs/heads/$branch_name"; then
                echo "Using existing local branch: $branch_name"
                if git worktree add "$worktree_path" "$branch_name"; then
                    echo "✅ Worktree created successfully: $branch_name"
                    echo "📍 Location: $worktree_path"
                    echo ""
                    echo "To navigate to the worktree: gwt goto"
                else
                    _gwt_create_worktree_error
                    return 1
                fi
            elif git show-ref --verify --quiet "refs/remotes/origin/$branch_name"; then
                echo "Creating worktree from remote branch: origin/$branch_name"
                if git worktree add "$worktree_path" -b "$branch_name" "origin/$branch_name"; then
                    echo "✅ Worktree created successfully: $branch_name"
                    echo "📍 Location: $worktree_path"
                    echo ""
                    echo "To navigate to the worktree: gwt goto"
                else
                    _gwt_create_worktree_error
                    return 1
                fi
            else
                _gwt_error "Branch '$branch_name' does not exist!" \
                    "\nAvailable branches:\n$(git branch -a | sed 's/^[* ] /  - /' | head -10)\n\nTo create a new branch: gwt create $branch_name"
                return 1
            fi
            ;;
            
        goto)
            # Count worktrees
            local worktree_count=0
            if [[ -d "$root_dir/$GWT_WORKTREE_DIR" ]]; then
                # Count directories more safely
                worktree_count=0
                for dir in "$root_dir/$GWT_WORKTREE_DIR"/*; do
                    [[ -d "$dir" ]] && ((worktree_count++))
                done 2>/dev/null
            fi
            
            # Check if any worktrees exist
            if [[ $worktree_count -eq 0 ]]; then
                echo "ℹ️  No worktrees found. You are in the main repository."
                echo ""
                echo "To create a worktree: gwt create <branch-name>"
                echo "Current location: $(pwd)"
                return 0
            fi
            
            # Get worktree list and select
            local options=$(_gwt_get_worktree_list "$root_dir" "$root_branch")
            local selected=$(printf "%b" "$options" | fzf --height 40% --reverse --prompt="Select worktree: " | awk '{print $2}')
            
            if [[ -n $selected ]]; then
                _gwt_change_to_worktree "$root_dir" "$selected" "$root_branch"
            else
                echo "ℹ️  No worktree selected."
            fi
            ;;
            
        remove)
            # Check if worktrees exist
            if [[ ! -d "$root_dir/$GWT_WORKTREE_DIR" ]] || [[ -z $(find "$root_dir/$GWT_WORKTREE_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null) ]]; then
                echo "ℹ️  No worktrees found to remove."
                echo ""
                echo "To create a worktree: gwt create <branch-name>"
                return 0
            fi
            
            # Use find to safely handle filenames with spaces
            local selected=$(find "$root_dir/$GWT_WORKTREE_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | fzf --height 40% --reverse --prompt="Remove worktree: ")
            if [[ -n $selected ]]; then
                echo "🗑️  Removing worktree: $selected"
                local worktree_path=$(_gwt_worktree_path "$root_dir" "$selected")
                
                # Get the branch name before removing worktree
                local branch_name=$(git -C "$worktree_path" branch --show-current 2>/dev/null)
                
                if git worktree remove "$worktree_path"; then
                    echo "✅ Successfully removed worktree: $selected"
                    
                    # Ask if user wants to delete the branch
                    echo ""
                    echo "🌿 Branch '$branch_name' still exists."
                    echo -n "Do you want to delete the branch? [y/N]: "
                    read -r response
                    
                    if [[ "$response" =~ ^[Yy]$ ]]; then
                        # Check if branch has unmerged changes
                        if git branch -d "$branch_name" 2>/dev/null; then
                            echo "✅ Successfully deleted branch: $branch_name"
                        else
                            echo "⚠️  Branch '$branch_name' has unmerged changes."
                            echo -n "Force delete? [y/N]: "
                            read -r force_response
                            
                            if [[ "$force_response" =~ ^[Yy]$ ]]; then
                                if git branch -D "$branch_name"; then
                                    echo "✅ Successfully force deleted branch: $branch_name"
                                else
                                    _gwt_error "Failed to delete branch: $branch_name"
                                fi
                            else
                                echo "ℹ️  Branch '$branch_name' was kept."
                            fi
                        fi
                    else
                        echo "ℹ️  Branch '$branch_name' was kept."
                    fi
                else
                    _gwt_error "Failed to remove worktree: $selected" \
                        "\nThe worktree might have uncommitted changes.\nTo force remove: git worktree remove --force $worktree_path"
                fi
            else
                echo "ℹ️  No worktree selected for removal."
            fi
            ;;
            
        list)
            _gwt_list_worktrees "$root_dir" "$root_branch"
            ;;
            
        help|"")
            echo "Git Worktree Manager (gwt)"
            echo ""
            echo "Commands:"
            echo "  gwt create <name>       Create new worktree with new branch"
            echo "  gwt createfrom <branch> Create worktree from existing branch"
            echo "  gwt goto                Navigate between worktrees (fzf)"
            echo "  gwt remove              Remove worktree (fzf)"
            echo "  gwt list                List all worktrees"
            echo "  gwt help                Show this help"
            echo ""
            echo "Examples:"
            echo "  gwt create feature-auth"
            echo "  gwt createfrom hotfix-123"
            echo "  gwt goto"
            echo "  gwt remove"
            ;;
            
        *)
            _gwt_error "Unknown command '$1'" \
                "\nRun 'gwt help' for available commands."
            ;;
    esac
}

# Tab補完の設定 (zsh only)
if [[ -n "$ZSH_VERSION" ]]; then
    _gwt_completion() {
    local -a commands
    commands=(
        'create:Create new worktree with new branch'
        'createfrom:Create worktree from existing branch'
        'goto:Navigate to worktree'
        'remove:Remove worktree'
        'list:List worktrees'
        'help:Show help'
    )
    
    if (( CURRENT == 2 )); then
        _describe 'command' commands
    elif (( CURRENT == 3 )); then
        case ${words[2]} in
            remove|goto)
                # worktreesディレクトリの中身を補完候補に
                local root_dir=$(git rev-parse --show-toplevel 2>/dev/null)
                if [[ -n $root_dir ]] && [[ -d "$root_dir/$GWT_WORKTREE_DIR" ]]; then
                    _path_files -W "$root_dir/$GWT_WORKTREE_DIR" -/
                fi
                ;;
            createfrom)
                # 既存のブランチを補完候補に
                local branches=($(git branch -a | sed 's/^[* ] //' | sed 's/^remotes\/origin\///' | sort -u 2>/dev/null))
                _describe 'branch' branches
                ;;
        esac
    fi
    }

    # Only set up completion if compdef is available and _comps is defined
    if command -v compdef &>/dev/null && [[ -n "${_comps+x}" ]]; then
        compdef _gwt_completion gwt
    fi
elif [[ -n "$BASH_VERSION" ]]; then
    # Bash completion
    _gwt_completion() {
        local cur prev
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        
        if [[ ${COMP_CWORD} -eq 1 ]]; then
            local commands="create createfrom goto remove list help"
            COMPREPLY=( $(compgen -W "${commands}" -- ${cur}) )
        elif [[ ${COMP_CWORD} -eq 2 ]]; then
            case ${prev} in
                remove|goto)
                    local root_dir=$(git rev-parse --show-toplevel 2>/dev/null)
                    if [[ -n $root_dir ]] && [[ -d "$root_dir/$GWT_WORKTREE_DIR" ]]; then
                        local worktrees=$(ls -1 "$root_dir/$GWT_WORKTREE_DIR" 2>/dev/null)
                        COMPREPLY=( $(compgen -W "${worktrees}" -- ${cur}) )
                    fi
                    ;;
                createfrom)
                    local branches=$(git branch -a | sed 's/^[* ] //' | sed 's/^remotes\/origin\///' | sort -u 2>/dev/null)
                    COMPREPLY=( $(compgen -W "${branches}" -- ${cur}) )
                    ;;
            esac
        fi
    }
    
    complete -F _gwt_completion gwt
fi
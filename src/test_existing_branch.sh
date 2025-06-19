#!/usr/bin/env bash

# Test script for existing branch support

set -e

echo "=== Testing gwt existing branch support ==="
echo ""

# スクリプトのディレクトリを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# テスト用の一時ディレクトリを作成
TEST_DIR="/tmp/gwt-test-$$"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# テスト用Gitリポジトリを初期化
echo "1. Setting up test repository..."
git init
echo "test" > test.txt
git add test.txt
git commit -m "Initial commit"

# gwtをロード
source "$SCRIPT_DIR/gwt.sh"

echo ""
echo "2. Testing new branch creation..."
gwt create feature-new
if [[ -d ".worktrees/feature-new" ]]; then
    echo "✓ New branch worktree created successfully"
else
    echo "✗ Failed to create new branch worktree"
    exit 1
fi

# メインに戻る
cd "$TEST_DIR"

echo ""
echo "3. Creating a test branch..."
git checkout -b test-existing
echo "existing branch" > existing.txt
git add existing.txt
git commit -m "Add existing.txt"
git checkout main

echo ""
echo "4. Testing existing branch support..."
gwt createfrom test-existing
if [[ -d ".worktrees/test-existing" ]]; then
    echo "✓ Existing branch worktree created successfully"
    # ファイルが存在するか確認
    if [[ -f ".worktrees/test-existing/existing.txt" ]]; then
        echo "✓ Branch content is correct"
    else
        echo "✗ Branch content is missing"
        exit 1
    fi
else
    echo "✗ Failed to create existing branch worktree"
    exit 1
fi

# メインに戻る
cd "$TEST_DIR"

echo ""
echo "5. Testing error handling (no branch name)..."
gwt create 2>/dev/null
if [[ $? -ne 0 ]]; then
    echo "✓ Error handling works correctly"
else
    echo "✗ Error handling failed"
    exit 1
fi

echo ""
echo "6. Cleaning up..."
rm -rf "$TEST_DIR"

echo ""
echo "=== All tests passed! ✓ ==="
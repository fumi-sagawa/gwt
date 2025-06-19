# 使い方ガイド

このガイドでは、Git Worktree Manager (gwt) の詳細な使い方を説明します。

## 📋 目次

- [基本概念](#基本概念)
- [コマンドリファレンス](#コマンドリファレンス)
- [実践的な使用例](#実践的な使用例)
- [高度な使い方](#高度な使い方)
- [ベストプラクティス](#ベストプラクティス)
- [統合とワークフロー](#統合とワークフロー)

## 基本概念

### Git Worktreeとは？

Git worktreeは、1つのGitリポジトリから複数の作業ディレクトリを作成できる機能です。各worktreeは独立したブランチを持ち、並行して作業できます。

### gwtの利点

1. **高速な切り替え**: `git stash`や`git checkout`なしでブランチ間を移動
2. **並行ビルド**: 各worktreeが独自のビルド成果物を保持
3. **クリーンな状態**: 作業中の変更を失うことなくブランチを切り替え
4. **効率的なCI/CD**: 複数のブランチで同時にテストを実行

## コマンドリファレンス

### `gwt create <name>`

新しいブランチでworktreeを作成します。

```bash
# 基本的な使用方法
gwt create feature-auth

# 結果
# - .worktrees/feature-auth ディレクトリが作成される
# - 新規ブランチが作成される
# - 作成のみ実行（移動は gwt goto で別途実行）
```

**使用例**:
```bash
# 新規ブランチの作成
gwt create feature-new-api

# エラーハンドリング
gwt create  # エラー: ブランチ名が必要です
```

### `gwt createfrom [branch]`

既存のブランチからworktreeを作成します。ブランチ名を指定しない場合、fzfで対話的に選択できます。

```bash
# 基本的な使用方法（ブランチ指定）
gwt createfrom hotfix-123

# fzfで対話的に選択
gwt createfrom

# 結果
# - .worktrees/[branch-name] ディレクトリが作成される
# - 既存ブランチを使用（worktreeで使用中のブランチは除外される）
# - 作成のみ実行（移動は gwt goto で別途実行）
```

**動作**:
1. ローカルに同名のブランチが存在する場合 → 既存ブランチを使用
2. リモート（origin）に同名のブランチが存在する場合 → リモートブランチから作成
3. どちらも存在しない場合 → エラー

**使用例**:
```bash
# 既存のローカルブランチから作成
gwt createfrom main  # mainブランチが既に存在

# リモートブランチから作成
gwt createfrom feature-remote  # origin/feature-remoteから作成

# エラーハンドリング
gwt createfrom  # エラー: ブランチ名が必要です
gwt createfrom non-existent  # エラー: ブランチが存在しません
```

### `gwt goto`

fzfを使用してworktree間を移動します。

```bash
# 基本的な使用方法
gwt goto

# インタラクティブな選択画面が表示される
┌─────────────────────────────────┐
│ Select worktree:                │
├─────────────────────────────────┤
│ > [main] .                      │
│   [feature-auth] feature-auth   │
│   [bugfix-login] bugfix-login   │
└─────────────────────────────────┘
```

**操作方法**:
- `↑`/`↓` または `Ctrl+P`/`Ctrl+N`: 選択を移動
- `Enter`: 選択したworktreeに移動
- `Esc` または `Ctrl+C`: キャンセル
- 文字入力: ファジー検索

**Tips**:
```bash
# エイリアスを設定してさらに高速に
alias g='gwt goto'
```

### `gwt remove`

不要になったworktreeを削除します。

```bash
# 基本的な使用方法
gwt remove

# 削除するworktreeを選択
┌─────────────────────────────────┐
│ Remove worktree:                │
├─────────────────────────────────┤
│ > feature-auth                  │
│   bugfix-login                  │
│   experiment-ai                 │
└─────────────────────────────────┘
```

**注意事項**:
- コミットされていない変更がある場合は警告が表示されます
- 強制削除が必要な場合は、`git worktree remove --force`を直接使用

### `gwt list`

すべてのworktreeとその状態を表示します。

```bash
# 基本的な使用方法
gwt list

# 出力例
🏠 Project: my-awesome-app

   . (root) [main]
📍 feature-auth [feature-auth]
   bugfix-login [bugfix-login]
   experiment-ai [experiment-ai]
```

**凡例**:
- `📍`: 現在いるworktree
- `[branch-name]`: 各worktreeのブランチ名
- `.`: プロジェクトルート

### `gwt help`

ヘルプメッセージを表示します。

```bash
gwt help

# 出力
Git Worktree Manager (gwt)

Commands:
  gwt create <name>       Create new worktree with new branch
  gwt createfrom [branch] Create worktree from existing branch
  gwt goto                Navigate between worktrees (fzf)
  gwt remove              Remove worktree (fzf)
  gwt list                List all worktrees
  gwt help                Show this help

Examples:
  gwt create feature-auth
  gwt createfrom hotfix-123
  gwt goto
  gwt remove
```

## 実践的な使用例

### シナリオ1: 機能開発中の緊急バグ修正

```bash
# 機能開発中
gwt create feature-shopping-cart
# ... 開発作業 ...

# 緊急のバグ報告が来た！
gwt create hotfix-payment-error

# バグ修正
vim src/payment.js
git add -A
git commit -m "fix: Resolve payment processing error"
git push origin hotfix-payment-error

# PRを作成してマージ

# 元の作業に戻る
gwt goto  # feature-shopping-cartを選択

# 不要になったhotfixブランチを削除
gwt remove  # hotfix-payment-errorを選択
```

### シナリオ2: 複数機能の並行開発

```bash
# Terminal 1: バックエンドAPI開発
gwt create feature-api-v2
npm run dev:api

# Terminal 2: フロントエンドUI開発  
gwt create feature-new-ui
npm run dev:frontend

# Terminal 3: ドキュメント更新
gwt goto  # mainを選択
npm run docs:serve

# 各ターミナルで独立して作業可能
```

### シナリオ3: コードレビューとテスト

```bash
# レビュー用にPRのブランチをチェックアウト
gwt createfrom review-pr-123
git pull origin feature-xyz

# テストを実行
npm test

# 元の作業に影響を与えずにレビュー
gwt goto  # 元のブランチに戻る
```

## 高度な使い方

### 環境変数の活用

```bash
# カスタムworktreeディレクトリ
export GWT_WORKTREE_DIR=".branches"

# fzfのカスタマイズ
export FZF_DEFAULT_OPTS='
  --height 60%
  --layout=reverse
  --border=rounded
  --preview "git log --oneline -n 10 {2}"
'
```

### シェル統合

#### プロンプトにworktree情報を表示

```bash
# ~/.zshrcに追加
gwt_prompt() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local worktree=$(basename $(git rev-parse --show-toplevel))
        local branch=$(git branch --show-current)
        echo "[$worktree:$branch]"
    fi
}

# プロンプトに組み込む
PS1='$(gwt_prompt) %~ $ '
```

#### 自動補完の強化

```bash
# カスタム補完関数
_gwt_custom() {
    local -a commands branches
    commands=(
        'create:Create new worktree with new branch'
        'createfrom:Create worktree from existing branch'
        'goto:Navigate to worktree'
        'remove:Remove worktree'
        'list:List worktrees'
        'clean:Remove all worktrees'
        'status:Show detailed status'
    )
    
    # ... 補完ロジック
}
```

### カスタムコマンドの追加

```bash
# ~/.zshrcに追加

# すべてのworktreeを削除
gwt_clean() {
    if [[ "$1" == "--force" ]]; then
        git worktree list | grep -v "bare" | awk '{print $1}' | \
        while read dir; do
            [[ "$dir" != "$(git rev-parse --show-toplevel)" ]] && \
            git worktree remove --force "$dir"
        done
    else
        echo "Use 'gwt_clean --force' to remove all worktrees"
    fi
}

# worktreeの詳細状態を表示
gwt_status() {
    git worktree list --porcelain | \
    while read -r line; do
        # パースして見やすく表示
        # ...
    done
}
```

## ベストプラクティス

### 1. 命名規則

一貫した命名規則を使用：

```bash
# 機能開発
gwt create feature-<機能名>

# バグ修正  
gwt create bugfix-<issue番号>
gwt create hotfix-<緊急度>-<内容>

# 実験
gwt create experiment-<実験内容>

# レビュー
gwt createfrom review-pr-<PR番号>
```

### 2. ライフサイクル管理

```bash
# 作業開始時
gwt create feature-awesome
git pull origin main
git merge main  # 最新のmainを取り込む

# 作業中
# ... コミット作業 ...

# 作業完了後
git push origin feature-awesome
# PR作成・マージ

# クリーンアップ
gwt remove  # feature-awesomeを選択
```

### 3. 大規模プロジェクトでの活用

```bash
# マイクロサービスごとにworktree
gwt create service-auth
gwt create service-payment
gwt create service-notification

# 各サービスで独立してテスト
cd .worktrees/service-auth && npm test
cd .worktrees/service-payment && npm test
```

## 統合とワークフロー

### VS Code統合

`.vscode/settings.json`:
```json
{
    "terminal.integrated.profiles.linux": {
        "gwt-zsh": {
            "path": "zsh",
            "args": ["-l"]
        }
    },
    "terminal.integrated.defaultProfile.linux": "gwt-zsh"
}
```

### CI/CD統合

```yaml
# .github/workflows/parallel-test.yml
name: Parallel Tests

on: [push, pull_request]

jobs:
  test:
    strategy:
      matrix:
        worktree: [main, develop, feature-branch]
    
    steps:
      - uses: actions/checkout@v2
      - name: Setup worktree
        run: |
          git worktree add .worktrees/${{ matrix.worktree }} ${{ matrix.worktree }}
          cd .worktrees/${{ matrix.worktree }}
      
      - name: Run tests
        run: |
          cd .worktrees/${{ matrix.worktree }}
          npm install
          npm test
```

### Gitフック統合

`.git/hooks/post-checkout`:
```bash
#!/bin/bash
# worktree切り替え時に依存関係を自動インストール

if [ -f package.json ]; then
    echo "Installing dependencies..."
    npm install
fi

if [ -f requirements.txt ]; then
    echo "Installing Python dependencies..."
    pip install -r requirements.txt
fi
```

### tmux統合

```bash
# tmux-gwt.sh
#!/bin/bash

# 各worktreeごとにtmuxウィンドウを作成
tmux new-session -d -s gwt
tmux rename-window -t gwt:0 "main"

for worktree in .worktrees/*; do
    if [ -d "$worktree" ]; then
        name=$(basename "$worktree")
        tmux new-window -t gwt -n "$name" -c "$worktree"
    fi
done

tmux attach -t gwt
```

---

より詳細な情報は[トラブルシューティング](troubleshooting.md)を参照してください。
# Git Worktree Manager (gwt) 🌲

<div align="center">

[![Shell: Bash/Zsh](https://img.shields.io/badge/Shell-Bash%2FZsh-green.svg)](https://www.gnu.org/software/bash/)
[![Dependencies: fzf](https://img.shields.io/badge/Dependencies-fzf-blue.svg)](https://github.com/junegunn/fzf)

**Git Worktreeを簡単に管理するためのシンプルで強力なツール**

[English](README_EN.md) | 日本語

</div>

## 📋 目次

- [概要](#-概要)
- [特徴](#-特徴)
- [デモ](#-デモ)
- [必要要件](#-必要要件)
- [インストール](#-インストール)
- [使い方](#-使い方)
- [設定](#-設定)
- [トラブルシューティング](#-トラブルシューティング)

## 🎯 概要

Git Worktree Manager (gwt) は、Gitのworktree機能をより使いやすくするためのコマンドラインツールです。複数のブランチで並行作業を行う際の切り替えを高速化し、開発効率を向上させます。

### なぜgwtを使うのか？

- **高速なコンテキストスイッチ**: `git stash`や`git checkout`を使わずに瞬時にブランチを切り替え
- **並行開発**: 複数の機能開発やバグ修正を同時に進行
- **クリーンな作業環境**: 各ブランチが独立したディレクトリを持つため、ビルドキャッシュの競合なし
- **直感的なインターフェース**: fzfを使った対話的な選択

## ✨ 特徴

- 🚀 **シンプルなコマンド**: `gwt create`、`gwt createfrom`、`gwt goto`、`gwt remove`、`gwt list`
- 🔍 **fzf統合**: 素早く直感的なworktree選択
- 📁 **自動ディレクトリ管理**: `.worktrees/`ディレクトリを自動作成・管理
- 🎨 **視覚的なリスト表示**: 現在のworktreeを分かりやすく表示
- 🔧 **Tab補完サポート**: zsh/bashでの自動補完
- 🏠 **プロジェクトルート対応**: どのworktreeからでも他のworktreeにアクセス可能
- 🌿 **既存ブランチ対応**: ローカル・リモートの既存ブランチからworktree作成可能
- ⚡ **エラーハンドリング**: 分かりやすいエラーメッセージとガイダンス

## 🎬 デモ

```bash
# 新しい機能ブランチを作成
$ gwt create feature-auth
Creating new branch: feature-auth
✅ Worktree created successfully: feature-auth
📍 Location: /path/to/project/.worktrees/feature-auth

To navigate to the worktree: gwt goto

# 既存ブランチから作成（fzfで選択）
$ gwt createfrom
┌─────────────────────────────────┐
│ Select branch (excluding worktrees): │
├─────────────────────────────────┤
│ > main                          │
│   develop                       │
│   origin/feature-x              │
└─────────────────────────────────┘

# worktree間を移動
$ gwt goto
┌─────────────────────────────────┐
│ Select worktree:                │
├─────────────────────────────────┤
│ > [main] .                      │
│   [feature-auth] feature-auth   │
│   [bugfix-login] bugfix-login   │
└─────────────────────────────────┘

# 現在の状況を確認
$ gwt list
🏠 Project: my-app

   . (root) [main]
📍 feature-auth [feature-auth]
   bugfix-login [bugfix-login]
```

## 📦 必要要件

- Git 2.5以上
- Bash 4.0以上 または Zsh 5.0以上
- [fzf](https://github.com/junegunn/fzf) (ファジーファインダー)

### fzfのインストール

```bash
# macOS
brew install fzf

# Ubuntu/Debian
sudo apt install fzf

# Arch Linux
sudo pacman -S fzf

# その他のOS
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

## 🚀 インストール

### 方法1: ライブラリとしてインストール（推奨）

.zshrcに1行追加するだけのクリーンなインストール方法です。

```bash
# リポジトリをクローン
git clone https://github.com/yourusername/gwt.git
cd gwt

# ライブラリインストールスクリプトを実行
./src/install-lib.sh
```

**インストール内容**:
- `~/.config/gwt/gwt.sh` にgwtライブラリを配置
- .zshrc/.bashrcに以下の1行を追加:
  ```bash
  [[ -f ~/.config/gwt/gwt.sh ]] && source ~/.config/gwt/gwt.sh
  ```

### 方法2: 直接.zshrcを編集

.zshrcを直接編集したい場合は、従来のインストール方法も使用できます。

```bash
./src/install.sh  # .zshrcにgwt.shの内容を直接追加
```

### 方法3: 手動インストール

1. **gwt.shを好きな場所にコピー**
```bash
cp src/gwt.sh ~/.config/gwt/
```

2. **.zshrcまたは.bashrcにsource文を追加**
```bash
echo '[[ -f ~/.config/gwt/gwt.sh ]] && source ~/.config/gwt/gwt.sh' >> ~/.zshrc
```

3. **設定を反映**
```bash
source ~/.zshrc  # zshの場合
source ~/.bashrc  # bashの場合
```

以上でインストールは完了です！

**注**: gwtは初回実行時に自動的に以下を行います：
- `.worktrees`ディレクトリの作成
- `.gitignore`への`.worktrees/`の追加（まだ追加されていない場合）

### 方法4: Dev Containerでの使用

開発環境でDev Containerを使用している場合、以下の方法でgwtを自動インストールできます：

#### GitHubから直接インストール（推奨）

`devcontainer.json`に以下を追加：

```json
"postCreateCommand": "curl -fsSL https://raw.githubusercontent.com/fumi-sagawa/gwt/main/src/install-lib.sh | bash"
```

#### Dockerfileでインストール

カスタムDockerfileを使用する場合：

```dockerfile
RUN git clone https://github.com/fumi-sagawa/gwt.git /tmp/gwt && \
    /tmp/gwt/src/install-lib.sh && \
    rm -rf /tmp/gwt
```

#### dotfilesリポジトリ経由

dotfilesリポジトリを持っている場合：

```json
"dotfiles": {
  "repository": "yourusername/dotfiles",
  "installCommand": "install.sh"
}
```

### アンインストール

```bash
# ライブラリインストールの場合
rm -rf ~/.config/gwt
# そして.zshrcからgwtの行を削除

# 直接インストールの場合
./src/uninstall.sh
```

## 📖 使い方

### 基本コマンド

| コマンド | 説明 |
|---------|------|
| `gwt create <name>` | 新しいブランチでworktreeを作成 |
| `gwt createfrom [branch]` | 既存ブランチからworktreeを作成（fzfで選択可能） |
| `gwt goto` | worktreeを選択して移動（fzf使用） |
| `gwt remove` | worktreeを選択して削除（fzf使用） |
| `gwt list` | すべてのworktreeをリスト表示 |
| `gwt help` | ヘルプを表示 |

### 典型的なワークフロー

```bash
# 1. プロジェクトに移動
cd ~/projects/my-app

# 2. 新機能の開発を開始
gwt create feature-payment

# 3. 開発作業...
echo "// Payment logic" >> payment.js
git add payment.js
git commit -m "feat: Add payment processing"

# 4. 緊急のバグ修正が必要になった
gwt create hotfix-security

# 5. バグ修正...
vim security.js
git add security.js
git commit -m "fix: Security vulnerability"
git push origin hotfix-security

# 6. 元の作業に戻る
gwt goto  # feature-paymentを選択

# 7. 作業完了後、worktreeを削除
gwt remove  # hotfix-securityを選択
```

### 並行開発の例

3つのターミナルで異なるタスクを同時進行：

```bash
# Terminal 1: API開発
gwt create feature-api
npm run dev

# Terminal 2: UIテスト
gwt create feature-ui
npm run test:watch

# Terminal 3: ドキュメント更新
gwt goto  # mainを選択
npm run docs:serve
```

## ⚙️ 設定

### 環境変数

```bash
# worktreeのデフォルトディレクトリを変更
export GWT_WORKTREE_DIR=".branches"  # デフォルトは .worktrees

# fzfのオプションをカスタマイズ
export FZF_DEFAULT_OPTS='--height 50% --layout=reverse --border'
```

### エイリアス

よく使うコマンドのショートカットを設定：

```bash
# ~/.zshrc または ~/.bashrc に追加
alias gwc='gwt create'
alias gwcf='gwt createfrom'
alias gwg='gwt goto'
alias gwr='gwt remove'
alias gwl='gwt list'
```

### プロジェクト別の設定

プロジェクトルートに`.gwtrc`を作成：

```bash
# .gwtrc
GWT_WORKTREE_DIR=".branches"
GWT_DEFAULT_BRANCH="develop"
```

## 📚 アーキテクチャ

### ライブラリとしての設計

gwtはシェル関数ライブラリとして設計されています：

```
~/.config/gwt/
└── gwt.sh         # メインライブラリファイル

~/.zshrc または ~/.bashrc
└── source ~/.config/gwt/gwt.sh  # 1行だけ追加
```

**利点**:
- .zshrcへの変更を最小限に抑える
- 更新が簡単（gwt.shを置き換えるだけ）
- アンインストールが簡単（~/.config/gwtを削除するだけ）
- 複数バージョンの管理が可能

### ディレクトリ構造

```
プロジェクトルート/
├── .git/
├── .gitignore    # .worktrees/を自動追加
├── .worktrees/   # gwtが管理するworktreeディレクトリ
│   ├── feature-auth/
│   ├── bugfix-login/
│   └── hotfix-security/
└── ... (プロジェクトファイル)
```

## 🔧 トラブルシューティング

### よくある問題と解決方法

<details>
<summary><strong>gwt: command not found</strong></summary>

シェルの設定ファイルが正しく読み込まれていない可能性があります：

```bash
# 現在のシェルを確認
echo $SHELL

# 設定を再読み込み
source ~/.zshrc  # zshの場合
source ~/.bashrc  # bashの場合
```
</details>

<details>
<summary><strong>fzf: command not found</strong></summary>

fzfがインストールされていません：

```bash
# インストール状況を確認
which fzf

# インストール
brew install fzf  # macOS
sudo apt install fzf  # Ubuntu/Debian
```
</details>

<details>
<summary><strong>worktreeが削除できない</strong></summary>

worktreeがロックされているか、変更が残っている可能性があります：

```bash
# 強制削除
git worktree remove --force .worktrees/branch-name

# それでも削除できない場合
rm -rf .worktrees/branch-name
git worktree prune
```
</details>

詳細なトラブルシューティングは[こちら](docs/troubleshooting.md)を参照してください。

## 🗑️ アンインストール

gwtをアンインストールする場合は、以下のコマンドを実行してください：

```bash
./src/uninstall.sh
```

このスクリプトは以下を実行します：
- シェル設定ファイルからgwtを削除
- バックアップファイルを作成
- 詳細な手順を表示

**注意**: 各プロジェクトのworktreeは自動削除されません。必要に応じて手動で削除してください。


## 🙏 謝辞

- [fzf](https://github.com/junegunn/fzf) - 素晴らしいファジーファインダー
- Git worktree機能の開発者の皆様
- このプロジェクトに貢献してくださったすべての方々

---

<div align="center">

**[⬆ トップに戻る](#git-worktree-manager-gwt-)**

Made with ❤️ by the gwt community

</div>
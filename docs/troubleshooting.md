# トラブルシューティングガイド

このガイドでは、Git Worktree Manager (gwt) を使用する際によく発生する問題とその解決方法を説明します。

## 📋 目次

- [インストール関連](#インストール関連)
- [実行時エラー](#実行時エラー)
- [Git Worktree関連](#git-worktree関連)
- [fzf関連](#fzf関連)
- [パフォーマンス問題](#パフォーマンス問題)
- [環境固有の問題](#環境固有の問題)
- [よくある質問](#よくある質問)

## インストール関連

### 問題: gwt: command not found

**症状**:
```bash
$ gwt help
zsh: command not found: gwt
```

**原因**: 
- シェルの設定ファイルにgwtが追加されていない
- 設定ファイルが読み込まれていない
- 間違ったシェル設定ファイルを編集した

**解決方法**:

1. 現在のシェルを確認:
```bash
echo $SHELL
# 出力例: /bin/zsh または /usr/bin/zsh
```

2. 正しい設定ファイルを確認:
```bash
# zshの場合
ls -la ~/.zshrc

# bashの場合
ls -la ~/.bashrc
```

3. インストール方法を確認:

**ライブラリインストールの場合**:
```bash
# gwt設定ファイルの確認
ls -la ~/.config/gwt/gwt.sh

# .zshrcに設定が含まれているか確認
grep "gwt.sh" ~/.zshrc
# 期待される出力: [[ -f ~/.config/gwt/gwt.sh ]] && source ~/.config/gwt/gwt.sh
```

**直接インストールの場合**:
```bash
grep "Git Worktree Manager" ~/.zshrc
```

4. 設定を再読み込み:
```bash
source ~/.zshrc  # zshの場合
source ~/.bashrc  # bashの場合
```

5. それでも動作しない場合は手動で追加:
```bash
cat gwt.sh >> ~/.zshrc
source ~/.zshrc
```

### 問題: Tab補完が機能しない

**症状**: 
- `gwt <Tab>`を押しても補完されない
- エラーメッセージが表示される

**解決方法**:

1. compdefが利用可能か確認（zshの場合）:
```bash
type compdef
# 出力: compdef is a shell function
```

2. 補完システムを初期化:
```bash
# ~/.zshrcに追加
autoload -Uz compinit
compinit
```

3. bashの場合は補完スクリプトを確認:
```bash
# ~/.bashrcに追加
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
```

## 実行時エラー

### 問題: Error: Not in a git repository

**症状**:
```bash
$ gwt ls
Error: Not in a git repository
```

**原因**: 現在のディレクトリがGitリポジトリではない

**解決方法**:

1. Gitリポジトリか確認:
```bash
git status
```

2. Gitリポジトリでない場合は初期化:
```bash
git init
```

3. または既存のリポジトリに移動:
```bash
cd /path/to/your/git/repository
```

### 問題: fatal: branch name required

**症状**:
```bash
$ gwt add
fatal: branch name required
```

**原因**: ブランチ名を指定していない

**解決方法**:
```bash
# 正しい使用方法
gwt add feature-name
```

## Git Worktree関連

### 問題: fatal: 'branch' is already checked out

**症状**:
```bash
$ gwt add main
fatal: 'main' is already checked out at '/path/to/repo'
```

**原因**: 指定したブランチが既に他のworktreeで使用されている

**解決方法**:

1. 現在のworktreeを確認:
```bash
git worktree list
```

2. 別の名前でworktreeを作成:
```bash
gwt add main-copy
```

3. または既存のworktreeに移動:
```bash
gwt go  # mainを選択
```

### 問題: Worktreeが削除できない

**症状**:
```bash
$ gwt rm
fatal: 'feature-branch' contains modified or untracked files, use --force to delete it
```

**原因**: 
- コミットされていない変更がある
- 追跡されていないファイルが存在する

**解決方法**:

1. 変更を確認:
```bash
cd .worktrees/feature-branch
git status
```

2. 変更を保存またはコミット:
```bash
git add -A
git commit -m "WIP: Save changes"
```

3. または強制削除（データが失われる可能性あり）:
```bash
git worktree remove --force .worktrees/feature-branch
```

### 問題: Worktreeが壊れている

**症状**:
- worktreeディレクトリは存在するが、gitが認識しない
- `git worktree list`に表示されない

**解決方法**:

1. 壊れたworktreeをクリーンアップ:
```bash
git worktree prune
```

2. 手動で削除してから再作成:
```bash
rm -rf .worktrees/broken-branch
git worktree prune
gwt add feature-branch
```

3. .git/worktreesを確認:
```bash
ls -la .git/worktrees/
# 不要なエントリを削除
rm -rf .git/worktrees/broken-branch
```

## fzf関連

### 問題: fzf: command not found

**症状**:
```bash
$ gwt go
gwt.sh: line 23: fzf: command not found
```

**解決方法**:

1. fzfをインストール:
```bash
# macOS
brew install fzf

# Ubuntu/Debian
sudo apt update
sudo apt install fzf

# 手動インストール
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

2. PATHを確認:
```bash
which fzf
echo $PATH
```

### 問題: fzfの表示が崩れる

**症状**:
- 文字化けする
- レイアウトが正しく表示されない

**解決方法**:

1. ターミナルのエンコーディングを確認:
```bash
echo $LANG
# UTF-8であることを確認
```

2. ターミナルエミュレータの設定を確認:
   - フォントがUnicode対応か
   - 文字エンコーディングがUTF-8か

3. fzfのオプションを調整:
```bash
export FZF_DEFAULT_OPTS='--no-unicode'
```

## パフォーマンス問題

### 問題: worktreeの作成が遅い

**症状**: `gwt add`の実行に時間がかかる

**原因**:
- 大きなリポジトリ
- ネットワークドライブ上での操作
- ディスクI/Oの問題

**解決方法**:

1. sparse-checkoutを使用:
```bash
git sparse-checkout init
git sparse-checkout set path/to/needed/files
```

2. shallow cloneを検討:
```bash
git clone --depth 1 <repository>
```

3. SSDを使用またはローカルディスクで作業

### 問題: fzfの検索が遅い

**解決方法**:

1. 検索対象を限定:
```bash
export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.*"'
```

2. ripgrepを使用:
```bash
brew install ripgrep
export FZF_DEFAULT_COMMAND='rg --files'
```

## 環境固有の問題

### macOS

#### 問題: .DS_Storeファイルが邪魔

**解決方法**:
```bash
# プロジェクトの.gitignoreに追加
echo ".DS_Store" >> .gitignore

# またはグローバルに無視（オプション）
echo ".DS_Store" >> ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
```

### Windows (WSL)

#### 問題: パスの問題

**症状**: Windowsパスとの混在でエラー

**解決方法**:
```bash
# WSL内でのみ作業
cd /home/user/projects
# Windowsパス（/mnt/c/...）は避ける
```

#### 問題: 改行コードの問題

**解決方法**:
```bash
# Gitの設定
git config --global core.autocrlf input
```

### Linux

#### 問題: 権限エラー

**症状**: Permission denied

**解決方法**:
```bash
# 実行権限を付与
chmod +x gwt.sh

# 所有者を確認
ls -la .worktrees/
```

## よくある質問

### Q: worktreeとブランチの違いは？

**A**: 
- **ブランチ**: Gitの履歴上のポインタ
- **worktree**: ブランチをチェックアウトした作業ディレクトリ

1つのブランチは1つのworktreeでのみチェックアウト可能です。

### Q: .worktreesディレクトリを変更できる？

**A**: はい、環境変数で変更可能です：

```bash
export GWT_WORKTREE_DIR=".branches"
```

### Q: worktreeを別のマシンと共有できる？

**A**: いいえ、worktreeはローカルマシン固有です。`.worktrees/`は`.gitignore`に追加することを推奨します。

### Q: 最大いくつのworktreeを作成できる？

**A**: Git自体に制限はありませんが、実用的には：
- ディスク容量
- メモリ使用量
- 管理の複雑さ

を考慮して10-20個程度が現実的です。

### Q: worktreeを使うべきでない場合は？

**A**: 以下の場合は通常のブランチ切り替えの方が適切：
- 非常に小さな変更
- ディスク容量が限られている
- 単純な線形開発フロー

### Q: エラーログはどこで確認できる？

**A**: Gitのデバッグ情報を有効化：

```bash
GIT_TRACE=1 gwt add feature-debug
```

### Q: gwtをアンインストールするには？

**A**: アンインストールスクリプトを使用してください：

```bash
./src/uninstall.sh
```

このスクリプトは以下を実行します：
- シェル設定ファイル（~/.zshrcまたは~/.bashrc）からgwtを削除
- バックアップファイルを作成
- アンインストール後の手順を案内

**注意**: 各プロジェクトのworktreeは自動的に削除されません。必要に応じて手動で削除してください：

```bash
cd /path/to/project
git worktree list
git worktree remove .worktrees/branch-name
```

---

問題が解決しない場合は、[Issues](https://github.com/yourusername/gwt/issues)で報告してください。
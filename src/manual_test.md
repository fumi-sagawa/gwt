# 既存ブランチサポートの手動テスト手順

## テスト環境の準備

```bash
# 1. テスト用ディレクトリを作成
mkdir ~/gwt-test-repo
cd ~/gwt-test-repo

# 2. Gitリポジトリを初期化
git init
echo "# Test Repo" > README.md
git add README.md
git commit -m "Initial commit"

# 3. gwtをロード
source /path/to/gwt.sh
```

## テストケース

### 1. 新規ブランチの作成
```bash
gwt add feature-new
# 期待: "Creating new branch: feature-new" と表示
# .worktrees/feature-new が作成される
```

### 2. 既存ローカルブランチからの作成
```bash
# まずテスト用ブランチを作成
git checkout -b test-existing
echo "test" > test.txt
git add test.txt
git commit -m "Add test file"
git checkout main

# 既存ブランチからworktreeを作成
gwt add test-existing
# 期待: "Using existing local branch: test-existing" と表示
# .worktrees/test-existing が作成される
```

### 3. リモートブランチからの作成
```bash
# リモートをシミュレート
git checkout -b remote-branch
echo "remote" > remote.txt
git add remote.txt
git commit -m "Add remote file"
git checkout main

# origin/remote-branchをシミュレート（実際の使用時は不要）
# gwt add remote-branch
# 期待: リモートブランチが存在する場合は "Creating worktree from remote branch: origin/remote-branch" と表示
```

### 4. エラーハンドリング
```bash
# ブランチ名なしでの実行
gwt add
# 期待: "Error: Branch name required" と表示
```

### 5. Git リポジトリ外での実行
```bash
cd /tmp
gwt add test
# 期待: "Error: Not in a git repository" と詳細なエラーメッセージが表示
```

## 確認項目

- [ ] 新規ブランチが正しく作成される
- [ ] 既存ブランチからworktreeが作成される
- [ ] エラーメッセージが適切に表示される
- [ ] 作成後、自動的にworktreeディレクトリに移動する
- [ ] .gitignoreに.worktrees/が追加される
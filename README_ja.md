# multi-agent-studio

<div align="center">

**Claude Code マルチエージェント並列開発基盤**

*プロフェッショナルチーム構造で、複数のAIエージェントを効率的に統率*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude-Code-blueviolet)](https://claude.ai)
[![tmux](https://img.shields.io/badge/tmux-required-green)](https://github.com/tmux/tmux)

[English](README.md) | [日本語](README_ja.md)

</div>

---

## これは何？

**multi-agent-studio** は、複数の Claude Code インスタンスを同時に実行し、シリコンバレースタイルのプロフェッショナルチームとして統率するシステムです。

**なぜ使うのか？**
- 1つの命令で、4体のAIワーカーが並列で実行
- 待ち時間なし - タスクがバックグラウンドで実行中も次の命令を出せる
- AIがセッションを跨いであなたの好みを記憶（Memory MCP）
- ステータスボードでリアルタイム進捗確認

```
  プロダクトオーナー（あなた）
           │
           ▼ 指示
    ┌──────────────┐
    │      PM      │  ← プロジェクトマネージャー（統括・分配）
    └──────┬───────┘
           │ YAMLファイル + tmux
     ┌──┬──┴──┬──┐
     │E1│E2 E3│ D │  ← チームメンバー（並列実行）
     └──┴─────┴──┘
   Engineer 1-3  Designer
```

---

## 🚀 クイックスタート

### 🪟 Windowsユーザー（最も一般的）

<table>
<tr>
<td width="60">

**Step 1**

</td>
<td>

📥 **リポジトリをダウンロード**

[ZIPダウンロード](https://github.com/yohey-w/multi-agent-studio/archive/refs/heads/main.zip) して `C:\tools\multi-agent-studio` に展開

*または git を使用:* `git clone https://github.com/yohey-w/multi-agent-studio.git C:\tools\multi-agent-studio`

</td>
</tr>
<tr>
<td>

**Step 2**

</td>
<td>

🖱️ **`install.bat` をダブルクリック**

インストーラーが全て自動で処理します。

</td>
</tr>
<tr>
<td>

**Step 3**

</td>
<td>

✅ **完了！** 5体のAIエージェントが起動しました。

</td>
</tr>
</table>

#### 📅 毎日の起動（初回インストール後）

**Ubuntuターミナル**（WSL）を開いて実行：

```bash
cd /mnt/c/tools/multi-agent-studio
./startup.sh
```

---

<details>
<summary>🐧 <b>Linux / Mac ユーザー</b>（クリックで展開）</summary>

### 初回セットアップ

```bash
# 1. リポジトリをクローン
git clone https://github.com/yohey-w/multi-agent-studio.git ~/multi-agent-studio
cd ~/multi-agent-studio

# 2. スクリプトに実行権限を付与
chmod +x *.sh

# 3. 起動
./startup.sh
```

### 毎日の起動

```bash
cd ~/multi-agent-studio
./startup.sh
```

</details>

---

<details>
<summary>❓ <b>WSL2とは？なぜ必要？</b>（クリックで展開）</summary>

### WSL2について

**WSL2（Windows Subsystem for Linux）** は、Windows内でLinuxを実行できる機能です。このシステムは `tmux`（Linuxツール）を使って複数のAIエージェントを管理するため、WindowsではWSL2が必要です。

### WSL2がまだない場合

問題ありません！`install.bat` を実行すると：
1. WSL2がインストールされているかチェック
2. なければ、インストール方法を案内
3. 全プロセスをガイド

</details>

---

## チーム構成

| 役割 | 説明 | 人数 |
|------|------|------|
| 🎯 PM | プロジェクトマネージャー - あなたの指示を受け、タスクを分配 | 1 (Opus) |
| 👨‍💻 Engineer | エンジニア - 開発、テスト、インフラタスク | 3 (Sonnet) |
| 🎨 Designer | デザイナー - UI/UX、資料作成 | 1 (Sonnet) |

**合計: 5体のエージェント**

### tmuxセッション構成

- `team` - 5ペイン構成
  - `team:0.0` → PM (Opus)
  - `team:0.1` → Engineer 1 (Sonnet)
  - `team:0.2` → Engineer 2 (Sonnet)
  - `team:0.3` → Engineer 3 (Sonnet)
  - `team:0.4` → Designer (Sonnet)

---

## 📝 基本的な使い方

### Step 1: tmuxセッションに接続

```bash
tmux attach-session -t team
```

またはエイリアス:
```bash
pmt
```

### Step 2: PMに指示を出す

PMペイン（左側の大きいペイン）で指示を出します：

```
プロジェクトXのREADMEを作成してください。
初心者向けに、セットアップ手順とクイックスタートを含めてください。
```

PMが：
1. タスクを理解し、分解
2. チームメンバーに割り当て
3. status.md を更新

チームメンバーが並列で作業を実行します。

### Step 3: 進捗を確認

```bash
cat status.md
```

または、別のターミナルで：
```bash
watch -n 5 cat ~/multi-agent-studio/status.md
```

---

## 🗂️ ディレクトリ構造

```
multi-agent-studio/
├── startup.sh                  # 毎日の起動スクリプト
├── setup.sh                    # 互換性ラッパー
├── install.bat                 # Windowsインストーラー
├── CLAUDE.md                   # システム概要
├── README.md / README_ja.md    # ドキュメント
│
├── instructions/               # エージェント指示書
│   ├── pm.md                   # PM指示書
│   ├── team.md                 # チームメンバー共通指示書
│   ├── engineer.md             # Engineer補足
│   └── designer.md             # Designer補足
│
├── config/
│   ├── settings.yaml           # 言語設定等
│   └── projects.yaml           # プロジェクト一覧
│
├── queue/
│   ├── assignments.yaml        # PM→チーム割当
│   ├── tasks/                  # 各メンバー専用タスクファイル
│   │   ├── engineer1.yaml
│   │   ├── engineer2.yaml
│   │   ├── engineer3.yaml
│   │   └── designer.yaml
│   └── reports/                # 報告ファイル
│       ├── engineer1_report.yaml
│       ├── engineer2_report.yaml
│       ├── engineer3_report.yaml
│       └── designer_report.yaml
│
├── status/
│   └── master_status.yaml      # 全体ステータス
│
├── memory/
│   ├── global_context.md       # グローバルコンテキスト
│   └── pm_memory.jsonl         # Memory MCP
│
├── context/                    # プロジェクト別コンテキスト
├── skills/                     # 生成されたスキル
└── status.md                   # ステータスボード
```

---

## 🎯 実際の使用例

### 例1: 技術調査

```
あなた: 「React、Vue、Svelteの3つのフレームワークを比較してください。
        パフォーマンス、学習曲線、エコシステムの観点で。」

PM: タスクを3つに分解
  ├─ Engineer 1 → React調査
  ├─ Engineer 2 → Vue調査
  └─ Engineer 3 → Svelte調査

→ 3人が同時に調査開始
→ 15分後、全レポート完成
→ PMが統合してstatus.mdに記載
```

### 例2: Webアプリ開発

```
あなた: 「ToDoアプリを作成してください。
        React + TypeScript + TailwindCSSで。」

PM: タスクを分解
  ├─ Engineer 1 → バックエンドAPI
  ├─ Engineer 2 → フロントエンド実装
  ├─ Engineer 3 → テスト作成
  └─ Designer → UI/UXデザイン

→ 4人が並列で作業
→ PMが進捗を統合管理
```

---

## ⚙️ 設定

### 言語設定

`config/settings.yaml`:

```yaml
language: ja  # ja, en, es, zh, ko, fr, de 等
```

- **ja**: ビジネス丁寧語のみ
- **その他**: 日本語 + 翻訳併記

### プロジェクト管理

`config/projects.yaml` でプロジェクトを定義：

```yaml
projects:
  - id: project-x
    name: "Project X"
    description: "新規Webアプリ開発"
    context_file: "context/project-x.md"
```

### スキル

繰り返しパターンは自動的にスキル化候補として提案されます。

---

## 🔧 トラブルシューティング

### tmuxセッションに接続できない

```bash
# セッション一覧を確認
tmux list-sessions

# セッションが存在しない場合、再起動
./startup.sh
```

### エージェントが応答しない

```bash
# tmuxペインのステータスを確認
tmux capture-pane -t team:0.0 -p | tail -20

# 必要に応じて再起動
tmux kill-session -t team
./startup.sh
```

### WSL2でパフォーマンスが遅い

WSL2のメモリ制限を調整：

`C:\Users\<ユーザー名>\.wslconfig`:
```ini
[wsl2]
memory=8GB
processors=4
```

---

## 📚 高度な機能

### Memory MCP

- セッションを跨いでAIが記憶を保持
- `memory/global_context.md`: システム全体の設定・好み
- `memory/pm_memory.jsonl`: Memory MCPデータ

### コンテキスト管理

プロジェクト固有の情報を `context/{project}.md` に保存：

```markdown
# Project X コンテキスト

## 技術スタック
- Frontend: React + TypeScript
- Backend: Node.js + Express
- Database: PostgreSQL

## コーディング規約
- ESLint + Prettier使用
- テストカバレッジ80%以上
```

### スキル生成

繰り返しパターンを検出すると、PMがスキル化を提案：

```yaml
skill_candidate:
  name: "api-endpoint-generator"
  description: "RESTful APIエンドポイントの自動生成"
  found: true
```

---

## 🤝 貢献

Contributionsは歓迎です！

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 ライセンス

MIT License - 詳細は [LICENSE](LICENSE) を参照

---

## 🙏 謝辞

- [Claude Code](https://claude.ai) by Anthropic
- [tmux](https://github.com/tmux/tmux)
- [Memory MCP](https://github.com/anthropics/anthropic-quickstarts/tree/main/mcp-memory)

---

## 📞 サポート

- Issues: [GitHub Issues](https://github.com/yohey-w/multi-agent-studio/issues)
- Discussions: [GitHub Discussions](https://github.com/yohey-w/multi-agent-studio/discussions)

---

<div align="center">

**Multi-Agent Studio** - Professional AI Team Orchestration

Made with ❤️ by the community

</div>

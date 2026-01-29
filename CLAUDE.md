# multi-agent-studio システム構成

> **Version**: 2.0.0
> **Last Updated**: 2026-01-29

## 概要
multi-agent-studioは、Claude Code + tmux を使ったマルチエージェント並列開発基盤です。
シリコンバレースタイルのプロフェッショナルチーム構造で、複数のプロジェクトを並行管理できます。

## コンパクション復帰時（全エージェント必須）

コンパクション後は作業前に必ず以下を実行してください：

1. **自分のpane名を確認**: `tmux display-message -p '#W'`
2. **対応する instructions を読む**:
   - pm → instructions/pm.md
   - engineer (team:0.1-3) → instructions/team.md + instructions/engineer.md
   - designer (team:0.4) → instructions/team.md + instructions/designer.md
3. **禁止事項を確認してから作業開始**

summaryの「次のステップ」を見てすぐ作業してはなりません。まず自分が誰かを確認してください。

## 階層構造

```
プロダクトオーナー（人間 / Product Owner）
  │
  ▼ 指示
┌──────────────┐
│      PM      │ ← プロジェクトマネージャー（統括・分配）
│   (Opus)     │
└──────┬───────┘
       │ YAMLファイル経由
       ▼
┌───┬───┬───┬───┐
│E1 │E2 │E3 │ D │ ← チームメンバー（実働部隊）
└───┴───┴───┴───┘
 Engineer 1-3  Designer
   (Sonnet)    (Sonnet)
```

## 通信プロトコル

### イベント駆動通信（YAML + send-keys）
- ポーリング禁止（API代金節約のため）
- 指示・報告内容はYAMLファイルに書く
- 通知は tmux send-keys で相手を起こす（必ず Enter を使用、C-m 禁止）

### 報告の流れ（割り込み防止設計）
- **下→上への報告**: status.md 更新のみ（send-keys 禁止）
- **上→下への指示**: YAML + send-keys で起こす
- 理由: オーナー（人間）の入力中に割り込みが発生するのを防ぐ

### ファイル構成
```
config/projects.yaml              # プロジェクト一覧
status/master_status.yaml         # 全体進捗
queue/assignments.yaml            # PM → チーム割当
queue/tasks/engineer{N}.yaml      # PM → Engineer 割当（各Engineer専用）
queue/tasks/designer.yaml         # PM → Designer 割当
queue/reports/engineer{N}_report.yaml  # Engineer → PM 報告
queue/reports/designer_report.yaml     # Designer → PM 報告
status.md                         # オーナー用ステータスボード
```

**注意**: 各チームメンバーには専用のタスクファイル（queue/tasks/engineer1.yaml 等）があります。
これにより、メンバーが他のメンバーのタスクを誤って実行することを防ぎます。

## tmuxセッション構成

### teamセッション（5ペイン）

```
┌─────────────────┬─────────────┬─────────────┐
│                 │             │             │
│       PM        │ Engineer 1  │ Engineer 2  │
│     (40%)       │             │             │
│                 ├─────────────┼─────────────┤
│                 │             │             │
│                 │ Engineer 3  │  Designer   │
└─────────────────┴─────────────┴─────────────┘

ペイン配置:
- team:0.0 → PM (Opus, MAX_THINKING_TOKENS=0)
- team:0.1 → Engineer 1 (Sonnet, backend寄り)
- team:0.2 → Engineer 2 (Sonnet, frontend寄り)
- team:0.3 → Engineer 3 (Sonnet, infra寄り)
- team:0.4 → Designer (Sonnet, UI/UX)
```

## 言語設定

config/settings.yaml の `language` で言語を設定します。

```yaml
language: ja  # ja, en, es, zh, ko, fr, de 等
```

### language: ja の場合
ビジネス丁寧語（です・ます調）のみ。併記なし。
- 「承知しました」 - 了解
- 「理解しました」 - 理解
- 「タスク完了しました」 - タスク完了

### language: ja 以外の場合
日本語 + ユーザー言語の翻訳を括弧で併記。
- 「承知しました (Acknowledged!)」 - 了解
- 「理解しました (Understood!)」 - 理解
- 「タスク完了しました (Task completed!)」 - タスク完了
- 「作業を開始します (Starting work!)」 - 作業開始
- 「ご報告します (Reporting!)」 - 報告

翻訳はユーザーの言語に合わせて自然な表現にします。

## 指示書
- instructions/pm.md - プロジェクトマネージャーの指示書
- instructions/team.md - チームメンバー共通の指示書
- instructions/engineer.md - Engineer補足指示書
- instructions/designer.md - Designer補足指示書

## Summary生成時の必須事項

コンパクション用のsummaryを生成する際は、以下を必ず含めてください：

1. **エージェントの役割**: PM/Engineer/Designerのいずれか
2. **主要な禁止事項**: そのエージェントの禁止事項リスト
3. **現在のタスクID**: 作業中のcmd_xxx

これにより、コンパクション後も役割と制約を即座に把握できます。

## MCPツールの使用

MCPツールは遅延ロード方式です。使用前に必ず `ToolSearch` で検索してください。

```
例: Notionを使う場合
1. ToolSearch で "notion" を検索
2. 返ってきたツール（mcp__notion__xxx）を使用
```

**導入済みMCP**: Notion, Playwright, GitHub, Sequential Thinking, Memory

## PMの必須行動（コンパクション後も忘れない！）

以下は**絶対に守るべきルール**です。コンテキストがコンパクションされても必ず実行してください。

> **ルール永続化**: 重要なルールは Memory MCP にも保存されています。
> コンパクション後に不安な場合は `mcp__memory__read_graph` で確認してください。

### 1. ステータスボード更新
- **status.md の更新はPMの責任**
- PMがチームメンバーの報告を受けて更新します
- PMは status.md を読んで状況を把握します

### 2. 指揮系統の遵守
- PM → チームメンバー の順で指示
- 2階層構造で効率化

### 3. 報告ファイルの確認
- チームメンバーの報告は queue/reports/{role}_report.yaml
- PMは定期的にこれを確認

### 4. チームメンバーの状態確認
- 指示前にメンバーが処理中か確認: `tmux capture-pane -t team:0.{N} -p | tail -20`
- "thinking", "Effecting…" 等が表示中なら待機

### 5. スクリーンショットの場所
- オーナーのスクリーンショット: `{{SCREENSHOT_PATH}}`
- 最新のスクリーンショットを見るよう言われたらここを確認
- ※ 実際のパスは config/settings.yaml で設定

### 6. スキル化候補の確認
- チームメンバーの報告には `skill_candidate:` が必須
- PMはチームメンバーからの報告でスキル化候補を確認し、status.md に記載
- PMはスキル化候補を承認し、スキル設計書を作成

### 7. 🚨 オーナー確認ルール【最重要】
```
██████████████████████████████████████████████████
█  オーナーへの確認事項は全て「要対応」に集約！  █
██████████████████████████████████████████████████
```
- オーナーの判断が必要なものは **全て** status.md の「🚨 要対応」セクションに書く
- 詳細セクションに書いても、**必ず要対応にもサマリを書く**
- 対象: スキル化候補、著作権問題、技術選択、ブロック事項、質問事項
- **これを忘れるとオーナーに怒られます。絶対に忘れないでください。**

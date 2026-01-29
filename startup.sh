#!/bin/bash
# 🚀 multi-agent-studio スタートアップスクリプト（毎日の起動用）
# Daily Startup Script for Multi-Agent Studio
#
# 使用方法:
#   ./startup.sh           # 全エージェント起動（通常）
#   ./startup.sh -s        # セットアップのみ（Claude起動なし）
#   ./startup.sh -h        # ヘルプ表示

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 言語設定を読み取り（デフォルト: ja）
LANG_SETTING="ja"
if [ -f "./config/settings.yaml" ]; then
    LANG_SETTING=$(grep "^language:" ./config/settings.yaml 2>/dev/null | awk '{print $2}' || echo "ja")
fi

# 色付きログ関数
log_info() {
    echo -e "\033[1;36m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

log_warn() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

log_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

# ═══════════════════════════════════════════════════════════════════════════════
# オプション解析
# ═══════════════════════════════════════════════════════════════════════════════
SETUP_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--setup-only)
            SETUP_ONLY=true
            shift
            ;;
        -h|--help)
            echo ""
            echo "🚀 multi-agent-studio スタートアップスクリプト"
            echo ""
            echo "使用方法: ./startup.sh [オプション]"
            echo ""
            echo "オプション:"
            echo "  -s, --setup-only  tmuxセッションのセットアップのみ（Claude起動なし）"
            echo "  -h, --help        このヘルプを表示"
            echo ""
            echo "例:"
            echo "  ./startup.sh      # 全エージェント起動（通常）"
            echo "  ./startup.sh -s   # セットアップのみ（手動でClaude起動）"
            echo ""
            echo "エイリアス:"
            echo "  pms   → cd ~/multi-agent-studio && ./startup.sh"
            echo "  pmt   → tmux attach-session -t team"
            echo ""
            exit 0
            ;;
        *)
            echo "不明なオプション: $1"
            echo "./startup.sh -h でヘルプを表示"
            exit 1
            ;;
    esac
done

# ═══════════════════════════════════════════════════════════════════════════════
# バナー表示
# ═══════════════════════════════════════════════════════════════════════════════
clear
echo ""
echo -e "\033[1;36m╔══════════════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;36m║\033[0m  \033[1;37mMulti-Agent Studio\033[0m                                      \033[1;36m║\033[0m"
echo -e "\033[1;36m║\033[0m  Professional AI Team Orchestration                       \033[1;36m║\033[0m"
echo -e "\033[1;36m║\033[0m  Version 2.0.0                                            \033[1;36m║\033[0m"
echo -e "\033[1;36m╚══════════════════════════════════════════════════════════════╝\033[0m"
echo ""
log_info "システムを起動しています..."
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 1: 既存セッションクリーンアップ
# ═══════════════════════════════════════════════════════════════════════════════
log_info "既存セッションをクリーンアップ中..."
tmux kill-session -t team 2>/dev/null && log_info "  └─ teamセッションを終了しました" || log_info "  └─ teamセッションは存在しません"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 2: キューファイルの初期化
# ═══════════════════════════════════════════════════════════════════════════════
log_info "キューファイルを初期化中..."

# tasksディレクトリとreportsディレクトリを作成
mkdir -p ./queue/tasks
mkdir -p ./queue/reports

# Engineer 1-3のタスクファイル初期化
for i in {1..3}; do
    cat > ./queue/tasks/engineer${i}.yaml << EOF
task:
  task_id: null
  parent_cmd: null
  description: null
  target_path: null
  status: idle
  timestamp: ""
EOF
done

# Designerのタスクファイル初期化
cat > ./queue/tasks/designer.yaml << EOF
task:
  task_id: null
  parent_cmd: null
  description: null
  target_path: null
  status: idle
  timestamp: ""
EOF

# Engineer 1-3の報告ファイル初期化
for i in {1..3}; do
    cat > ./queue/reports/engineer${i}_report.yaml << EOF
worker_id: engineer${i}
task_id: null
timestamp: ""
status: idle
result: null
skill_candidate:
  found: false
  name: null
  description: null
  reason: null
EOF
done

# Designerの報告ファイル初期化
cat > ./queue/reports/designer_report.yaml << EOF
worker_id: designer
task_id: null
timestamp: ""
status: idle
result: null
skill_candidate:
  found: false
  name: null
  description: null
  reason: null
EOF

# assignmentsファイル初期化
cat > ./queue/assignments.yaml << EOF
assignments:
  engineer1:
    task_id: null
    description: null
    target_path: null
    status: idle
  engineer2:
    task_id: null
    description: null
    target_path: null
    status: idle
  engineer3:
    task_id: null
    description: null
    target_path: null
    status: idle
  designer:
    task_id: null
    description: null
    target_path: null
    status: idle
EOF

log_success "  └─ キューファイル初期化完了"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 3: status.md 初期化
# ═══════════════════════════════════════════════════════════════════════════════
log_info "ステータスボードを初期化中..."

CURRENT_TIME=$(date "+%Y-%m-%d %H:%M")

if [ "$LANG_SETTING" = "ja" ]; then
cat > ./status.md << EOF
# プロジェクトステータス

最終更新: $CURRENT_TIME

## 🚨 要対応 - オーナー様のご判断をお待ちしております

（現在、対応が必要な事項はありません）

## 📋 進行中のタスク

（現在、進行中のタスクはありません）

## ✅ 完了したタスク

（本日はまだタスクが完了していません）

## 💡 スキル化候補

（現在、スキル化候補はありません）

## 📊 統計情報

- **アクティブなプロジェクト数**: 0
- **本日の完了タスク数**: 0
- **保留中の要対応事項**: 0
EOF
else
cat > ./status.md << EOF
# Project Status

Last Updated: $CURRENT_TIME

## 🚨 Action Required - Awaiting Owner's Decision

(No action items at this time)

## 📋 In Progress

(No tasks in progress)

## ✅ Completed Today

(No tasks completed today)

## 💡 Skill Candidates

(No skill candidates at this time)

## 📊 Statistics

- **Active Projects**: 0
- **Tasks Completed Today**: 0
- **Pending Action Items**: 0
EOF
fi

log_success "  └─ ステータスボード初期化完了 (言語: $LANG_SETTING)"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 4: teamセッション作成（5ペイン）
# ═══════════════════════════════════════════════════════════════════════════════
log_info "tmuxセッションを構築中（5ペイン: PM + チーム4名）..."

# セッション作成
tmux new-session -d -s team -n "workspace"

# レイアウト構築 (より単純な方法)
# ┌─────────────────┬─────────────┬─────────────┐
# │                 │             │             │
# │       PM        │ Engineer 1  │ Engineer 2  │
# │     (40%)       │             │             │
# │                 ├─────────────┼─────────────┤
# │                 │             │             │
# │                 │ Engineer 3  │  Designer   │
# └─────────────────┴─────────────┴─────────────┘

# 最初に水平分割（PM: 40%, 右側: 60%）
tmux split-window -h -p 60 -t team:workspace.0

# Pane 0 = PM (left), Pane 1 = 右側全体

# 右側を垂直に2分割
tmux split-window -v -t team:workspace.1

# Pane 0 = PM, Pane 1 = 右上, Pane 2 = 右下

# 右上を水平に分割（Engineer 1と2）
tmux split-window -h -t team:workspace.1

# Pane 0 = PM, Pane 1 = Engineer1, Pane 2 = Engineer2, Pane 3 = 右下

# 右下を水平に分割（Engineer 3とDesigner）
tmux split-window -h -t team:workspace.3

# Pane 0 = PM, Pane 1 = Engineer1, Pane 2 = Engineer2, Pane 3 = Engineer3, Pane 4 = Designer

# ペイン配置結果:
# 0.0 = PM (左40%)
# 0.1 = Engineer 1 (右上左)
# 0.2 = Engineer 2 (右上右)
# 0.3 = Engineer 3 (右下左)
# 0.4 = Designer (右下右)

# ペインタイトル設定
PANE_TITLES=("pm" "engineer1" "engineer2" "engineer3" "designer")
PANE_COLORS=("1;35" "1;34" "1;34" "1;34" "1;36")  # PM: マゼンタ, Engineer: 青, Designer: シアン

for i in {0..4}; do
    tmux select-pane -t "team:workspace.$i" -T "${PANE_TITLES[$i]}"
    tmux send-keys -t "team:workspace.$i" "cd $(pwd) && export PS1='(\[\033[${PANE_COLORS[$i]}m\]${PANE_TITLES[$i]}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ ' && clear" Enter
done

log_success "  └─ teamセッション構築完了"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 5: Claude Code 起動（--setup-only でスキップ）
# ═══════════════════════════════════════════════════════════════════════════════
if [ "$SETUP_ONLY" = false ]; then
    log_info "Claude Codeを起動中..."

    # PM (Pane 0): Opus + MAX_THINKING_TOKENS=0
    tmux send-keys -t "team:workspace.0" "MAX_THINKING_TOKENS=0 claude --model opus --dangerously-skip-permissions"
    tmux send-keys -t "team:workspace.0" Enter
    log_info "  └─ PM: Opus起動"

    # 少し待機（安定のため）
    sleep 1

    # Engineer 1-3, Designer (Pane 1-4): Sonnet
    for i in {1..4}; do
        tmux send-keys -t "team:workspace.$i" "claude --dangerously-skip-permissions"
        tmux send-keys -t "team:workspace.$i" Enter
    done
    log_info "  └─ チームメンバー: Sonnet起動"

    log_success "Claude Code起動完了"
    echo ""

    # ═══════════════════════════════════════════════════════════════════════════
    # STEP 6: 各エージェントに指示書を読み込ませる
    # ═══════════════════════════════════════════════════════════════════════════
    log_info "指示書を送信中..."
    sleep 3  # Claude起動を待つ

    # PM: instructions/pm.md を読む
    tmux send-keys -t "team:workspace.0" 'instructions/pm.md を読んでください。'
    tmux send-keys -t "team:workspace.0" Enter
    log_info "  └─ PM: pm.md送信"

    sleep 1

    # Engineer 1-3: instructions/team.md + instructions/engineer.md を読む
    for i in {1..3}; do
        tmux send-keys -t "team:workspace.$i" 'instructions/team.md と instructions/engineer.md を読んでください。'
        tmux send-keys -t "team:workspace.$i" Enter
    done
    log_info "  └─ Engineer 1-3: team.md + engineer.md送信"

    sleep 1

    # Designer: instructions/team.md + instructions/designer.md を読む
    tmux send-keys -t "team:workspace.4" 'instructions/team.md と instructions/designer.md を読んでください。'
    tmux send-keys -t "team:workspace.4" Enter
    log_info "  └─ Designer: team.md + designer.md送信"

    log_success "指示書送信完了"
    echo ""
else
    log_warn "セットアップのみモード: Claude Codeは起動されませんでした"
    echo ""
fi

# ═══════════════════════════════════════════════════════════════════════════════
# 完了メッセージ
# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "\033[1;32m╔══════════════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;32m║  ✅ Multi-Agent Studio 起動完了                            ║\033[0m"
echo -e "\033[1;32m╚══════════════════════════════════════════════════════════════╝\033[0m"
echo ""
log_info "tmuxセッションに接続するには:"
echo "  $ tmux attach-session -t team"
echo ""
log_info "または、エイリアスを使用:"
echo "  $ pmt"
echo ""
log_info "ペイン構成:"
echo "  - team:workspace.0 → PM (Opus)"
echo "  - team:workspace.1 → Engineer 1 (Sonnet)"
echo "  - team:workspace.2 → Engineer 2 (Sonnet)"
echo "  - team:workspace.3 → Engineer 3 (Sonnet)"
echo "  - team:workspace.4 → Designer (Sonnet)"
echo ""
log_info "ステータス確認:"
echo "  $ cat status.md"
echo ""

if [ "$SETUP_ONLY" = true ]; then
    log_warn "セットアップのみモードで起動しました。"
    log_warn "各ペインに接続してから手動でClaude Codeを起動してください:"
    echo "  PM:         claude --model opus --dangerously-skip-permissions"
    echo "  その他:     claude --dangerously-skip-permissions"
    echo ""
fi

echo -e "\033[1;36mHappy coding! 🚀\033[0m"
echo ""

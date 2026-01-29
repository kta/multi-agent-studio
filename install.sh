#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# install.sh - Multi-Agent Studio インストーラー（Mac用）
# ═══════════════════════════════════════════════════════════════════════════════
# macOS用の自動インストールスクリプト
# 必要な依存関係をチェック・インストールし、システムをセットアップします。
# ═══════════════════════════════════════════════════════════════════════════════

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

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

# バナー表示
clear
echo ""
echo -e "\033[1;36m╔══════════════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;36m║\033[0m  \033[1;37m🚀 Multi-Agent Studio - Auto Installer\033[0m                  \033[1;36m║\033[0m"
echo -e "\033[1;36m║\033[0m     全自動セットアップ（macOS用）                           \033[1;36m║\033[0m"
echo -e "\033[1;36m╚══════════════════════════════════════════════════════════════╝\033[0m"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 1: macOSの確認
# ═══════════════════════════════════════════════════════════════════════════════
log_info "[1/5] macOSの確認中..."
if [[ "$OSTYPE" != "darwin"* ]]; then
    log_error "このスクリプトはmacOS専用です"
    log_error "OS: $OSTYPE"
    exit 1
fi
log_success "  └─ macOS確認完了"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 2: Homebrewのインストール確認
# ═══════════════════════════════════════════════════════════════════════════════
log_info "[2/5] Homebrewの確認中..."
if ! command -v brew &> /dev/null; then
    log_warn "  └─ Homebrewが見つかりません。インストール中..."
    echo ""
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Homebrewのパスを設定（Apple SiliconとIntelで異なる）
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    log_success "  └─ Homebrewインストール完了"
else
    log_success "  └─ Homebrew OK"
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 3: tmuxのインストール確認
# ═══════════════════════════════════════════════════════════════════════════════
log_info "[3/5] tmuxの確認中..."
if ! command -v tmux &> /dev/null; then
    log_warn "  └─ tmuxが見つかりません。インストール中..."
    brew install tmux
    log_success "  └─ tmuxインストール完了"
else
    log_success "  └─ tmux OK ($(tmux -V))"
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 4: Claude Codeのインストール確認
# ═══════════════════════════════════════════════════════════════════════════════
log_info "[4/5] Claude Codeの確認中..."
if ! command -v claude &> /dev/null; then
    log_warn "  └─ Claude Codeが見つかりません。"
    echo ""
    echo -e "\033[1;33m╔══════════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[1;33m║  ⚠️  Claude Codeのインストールが必要です                   ║\033[0m"
    echo -e "\033[1;33m╚══════════════════════════════════════════════════════════════╝\033[0m"
    echo ""
    echo "Claude Codeは手動でインストールする必要があります："
    echo ""
    echo "1. 公式サイトにアクセス:"
    echo "   https://docs.anthropic.com/en/docs/claude-code"
    echo ""
    echo "2. インストール手順に従ってClaude Codeをインストール"
    echo ""
    echo "3. インストール後、再度このスクリプトを実行:"
    echo "   ./install.sh"
    echo ""
    exit 1
else
    log_success "  └─ Claude Code OK ($(claude --version 2>&1 | head -n1 || echo 'version unknown'))"
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 5: ディレクトリ構成の確認・初期化
# ═══════════════════════════════════════════════════════════════════════════════
log_info "[5/5] ディレクトリ構成の確認中..."

# 必要なディレクトリを作成
mkdir -p ./queue/tasks
mkdir -p ./queue/reports
mkdir -p ./config
mkdir -p ./instructions
mkdir -p ./status
mkdir -p ./context
mkdir -p ./skills

log_success "  └─ ディレクトリ構成OK"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# インストール完了
# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "\033[1;32m╔══════════════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;32m║  ✅ インストール完了！                                      ║\033[0m"
echo -e "\033[1;32m╚══════════════════════════════════════════════════════════════╝\033[0m"
echo ""

# エイリアス設定の提案
log_info "便利なエイリアスを設定できます（オプション）:"
echo ""
echo "以下を ~/.zshrc または ~/.bash_profile に追加:"
echo ""
echo "  # Multi-Agent Studio aliases"
echo "  alias pms='cd $SCRIPT_DIR && ./startup.sh'"
echo "  alias pmt='tmux attach-session -t team'"
echo ""

# 次のステップ
echo -e "\033[1;36m┌──────────────────────────────────────────────────────────┐\033[0m"
echo -e "\033[1;36m│  🚀 次のステップ: システム起動                           │\033[0m"
echo -e "\033[1;36m├──────────────────────────────────────────────────────────┤\033[0m"
echo -e "\033[1;36m│\033[0m                                                          \033[1;36m│\033[0m"
echo -e "\033[1;36m│\033[0m  以下のコマンドでシステムを起動:                        \033[1;36m│\033[0m"
echo -e "\033[1;36m│\033[0m                                                          \033[1;36m│\033[0m"
echo -e "\033[1;36m│\033[0m    \033[1;37m./startup.sh\033[0m                                        \033[1;36m│\033[0m"
echo -e "\033[1;36m│\033[0m                                                          \033[1;36m│\033[0m"
echo -e "\033[1;36m│\033[0m  または、エイリアスを設定した場合:                      \033[1;36m│\033[0m"
echo -e "\033[1;36m│\033[0m                                                          \033[1;36m│\033[0m"
echo -e "\033[1;36m│\033[0m    \033[1;37mpms\033[0m                                                \033[1;36m│\033[0m"
echo -e "\033[1;36m│\033[0m                                                          \033[1;36m│\033[0m"
echo -e "\033[1;36m└──────────────────────────────────────────────────────────┘\033[0m"
echo ""
log_info "オプション:"
echo "  ./startup.sh -h    ヘルプ表示"
echo "  ./startup.sh -s    セットアップのみ（Claude起動なし）"
echo ""

echo -e "\033[1;36mHappy coding! 🚀\033[0m"
echo ""

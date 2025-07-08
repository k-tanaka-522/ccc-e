#!/bin/bash

# 🔄 Enterprise Agent Workflow Manager
# エージェント間の協調作業を管理

# 設定
WORKFLOW_VERSION="1.0.0"
AGENT_SEND="./agents/core/agent-send.sh"

# カラー設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# ログ関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# ワークフロー実行
execute_workflow() {
    local workflow_type="$1"
    local project_description="$2"
    
    echo -e "${PURPLE}🚀 Enterprise Agent Workflow を開始${NC}"
    echo "=================================="
    echo "ワークフロー: $workflow_type"
    echo "プロジェクト: $project_description"
    echo ""
    
    case "$workflow_type" in
        "full")
            execute_full_workflow "$project_description"
            ;;
        "requirements")
            execute_requirements_only "$project_description"
            ;;
        "design")
            execute_design_workflow "$project_description"
            ;;
        "development")
            execute_development_workflow "$project_description"
            ;;
        *)
            log_error "不明なワークフロー: $workflow_type"
            show_usage
            exit 1
            ;;
    esac
}

# フルワークフロー実行
execute_full_workflow() {
    local project_description="$1"
    
    log_info "フルワークフロー開始: $project_description"
    
    # 1. 要件定義
    log_info "📋 Step 1: 要件定義"
    if [ -f "$AGENT_SEND" ]; then
        $AGENT_SEND requirements "要件定義を開始してください。プロジェクト: $project_description"
        sleep 2
    fi
    
    # 2. アーキテクチャ設計
    log_info "🏗️  Step 2: アーキテクチャ設計"
    if [ -f "$AGENT_SEND" ]; then
        $AGENT_SEND architect "要件定義に基づいてアーキテクチャ設計を開始してください。"
        sleep 2
    fi
    
    # 3. UI/UXデザイン
    log_info "🎨 Step 3: UI/UXデザイン"
    if [ -f "$AGENT_SEND" ]; then
        $AGENT_SEND uiux "要件に基づいてデザインシステムを作成してください。"
        sleep 2
    fi
    
    # 4. 開発・実装
    log_info "💻 Step 4: 開発・実装"
    if [ -f "$AGENT_SEND" ]; then
        $AGENT_SEND developer "設計に基づいて実装を開始してください。"
        sleep 2
    fi
    
    # 5. SRE設定
    log_info "🔧 Step 5: SRE設定"
    if [ -f "$AGENT_SEND" ]; then
        $AGENT_SEND sre "運用監視設定を作成してください。"
        sleep 2
    fi
    
    log_success "フルワークフロー送信完了"
}

# 要件定義のみ実行
execute_requirements_only() {
    local project_description="$1"
    
    log_info "要件定義ワークフロー開始: $project_description"
    
    if [ -f "$AGENT_SEND" ]; then
        $AGENT_SEND requirements "詳細な要件定義を作成してください。プロジェクト: $project_description"
        log_success "要件定義エージェントに送信完了"
    else
        log_error "agent-send.shが見つかりません"
    fi
}

# 設計ワークフロー実行
execute_design_workflow() {
    local project_description="$1"
    
    log_info "設計ワークフロー開始: $project_description"
    
    # アーキテクチャ設計
    if [ -f "$AGENT_SEND" ]; then
        $AGENT_SEND architect "アーキテクチャ設計を開始してください。"
        sleep 1
        $AGENT_SEND uiux "デザインシステムを作成してください。"
        log_success "設計エージェントに送信完了"
    else
        log_error "agent-send.shが見つかりません"
    fi
}

# 開発ワークフロー実行
execute_development_workflow() {
    local project_description="$1"
    
    log_info "開発ワークフロー開始: $project_description"
    
    # 開発とSRE
    if [ -f "$AGENT_SEND" ]; then
        $AGENT_SEND developer "実装を開始してください。"
        sleep 1
        $AGENT_SEND sre "運用設定を作成してください。"
        log_success "開発エージェントに送信完了"
    else
        log_error "agent-send.shが見つかりません"
    fi
}

# エージェント状態確認
check_agent_status() {
    log_info "エージェント状態を確認しています..."
    
    if [ -f "$AGENT_SEND" ]; then
        $AGENT_SEND --list
    else
        log_error "agent-send.shが見つかりません"
    fi
}

# 使用方法表示
show_usage() {
    cat << EOF
🔄 Enterprise Agent Workflow Manager v${WORKFLOW_VERSION}
================================================

使用方法:
  $0 [ワークフロー] [プロジェクト説明]

ワークフロー:
  full         - フルワークフロー（要件→設計→開発→運用）
  requirements - 要件定義のみ
  design       - 設計のみ（アーキテクチャ + UI/UX）
  development  - 開発のみ（実装 + SRE）

オプション:
  --status     - エージェント状態確認
  --help       - このヘルプを表示

例:
  $0 full "ECサイトを構築したい"
  $0 requirements "社内管理システム"
  $0 design "モバイルアプリ"
  $0 --status

EOF
}

# メイン処理
main() {
    case "$1" in
        --status)
            check_agent_status
            ;;
        --help|"")
            show_usage
            ;;
        *)
            if [ -z "$2" ]; then
                log_error "プロジェクト説明を指定してください"
                show_usage
                exit 1
            fi
            execute_workflow "$1" "$2"
            ;;
    esac
}

# 実行
main "$@"
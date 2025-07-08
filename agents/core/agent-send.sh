#!/bin/bash

# 🚀 Agent間メッセージ送信スクリプト

# tmuxのbase-indexとpane-base-indexを動的に取得
get_tmux_indices() {
    local session="$1"
    local window_index=$(tmux show-options -t "$session" -g base-index 2>/dev/null | awk '{print $2}')
    local pane_index=$(tmux show-options -t "$session" -g pane-base-index 2>/dev/null | awk '{print $2}')

    # デフォルト値
    window_index=${window_index:-0}
    pane_index=${pane_index:-0}

    echo "$window_index $pane_index"
}

# エージェント→tmuxターゲット マッピング
get_agent_target() {
    case "$1" in
        "president") echo "president" ;;
        "boss1"|"worker1"|"worker2"|"worker3")
            # multiagentセッションのindexを動的に取得
            if tmux has-session -t multiagent 2>/dev/null; then
                local indices=($(get_tmux_indices multiagent))
                local window_index=${indices[0]}
                local pane_index=${indices[1]}

                # window名で取得（base-indexに依存しない）
                local window_name="agents"

                # pane番号を計算
                case "$1" in
                    "boss1") echo "multiagent:$window_name.$((pane_index))" ;;
                    "worker1") echo "multiagent:$window_name.$((pane_index + 1))" ;;
                    "worker2") echo "multiagent:$window_name.$((pane_index + 2))" ;;
                    "worker3") echo "multiagent:$window_name.$((pane_index + 3))" ;;
                esac
            else
                echo ""
            fi
            ;;
        # 新しいエージェント（enterpriseセッション）
        "requirements"|"architect"|"developer"|"uiux"|"sre")
            if tmux has-session -t enterprise 2>/dev/null; then
                local indices=($(get_tmux_indices enterprise))
                local window_index=${indices[0]}
                local pane_index=${indices[1]}

                # window名で取得
                local window_name="agents"

                # pane番号を計算
                case "$1" in
                    "requirements") echo "enterprise:$window_name.$((pane_index))" ;;
                    "architect") echo "enterprise:$window_name.$((pane_index + 1))" ;;
                    "developer") echo "enterprise:$window_name.$((pane_index + 2))" ;;
                    "uiux") echo "enterprise:$window_name.$((pane_index + 3))" ;;
                    "sre") echo "enterprise:$window_name.$((pane_index + 4))" ;;
                esac
            else
                echo ""
            fi
            ;;
        *) echo "" ;;
    esac
}

show_usage() {
    cat << EOF
🤖 Agent間メッセージ送信

使用方法:
  $0 [エージェント名] [メッセージ]
  $0 --list

利用可能エージェント:
  president     - プロジェクト統括責任者
  boss1         - チームリーダー  
  worker1       - 実行担当者A
  worker2       - 実行担当者B
  worker3       - 実行担当者C
  requirements  - 要件定義エージェント
  architect     - アーキテクチャ設計エージェント
  developer     - 開発・実装エージェント
  uiux          - UI/UXデザインエージェント
  sre           - SRE運用エージェント

使用例:
  $0 president "指示書に従って"
  $0 boss1 "Hello World プロジェクト開始指示"
  $0 requirements "ECサイトの要件定義を開始"
  $0 architect "要件に基づいてAWS設計を実行"
  $0 developer "APIとフロントエンドを実装"
EOF
}

# エージェント一覧表示
show_agents() {
    echo "📋 利用可能なエージェント:"
    echo "=========================="

    # presidentセッション確認
    if tmux has-session -t president 2>/dev/null; then
        echo "  president → president       (プロジェクト統括責任者)"
    else
        echo "  president → [未起動]        (プロジェクト統括責任者)"
    fi

    # multiagentセッション確認
    if tmux has-session -t multiagent 2>/dev/null; then
        local boss1_target=$(get_agent_target "boss1")
        local worker1_target=$(get_agent_target "worker1")
        local worker2_target=$(get_agent_target "worker2")
        local worker3_target=$(get_agent_target "worker3")

        echo "  boss1     → ${boss1_target:-[エラー]}  (チームリーダー)"
        echo "  worker1   → ${worker1_target:-[エラー]}  (実行担当者A)"
        echo "  worker2   → ${worker2_target:-[エラー]}  (実行担当者B)"
        echo "  worker3   → ${worker3_target:-[エラー]}  (実行担当者C)"
    else
        echo "  boss1     → [未起動]        (チームリーダー)"
        echo "  worker1   → [未起動]        (実行担当者A)"
        echo "  worker2   → [未起動]        (実行担当者B)"
        echo "  worker3   → [未起動]        (実行担当者C)"
    fi

    # enterpriseセッション確認
    if tmux has-session -t enterprise 2>/dev/null; then
        local requirements_target=$(get_agent_target "requirements")
        local architect_target=$(get_agent_target "architect")
        local developer_target=$(get_agent_target "developer")
        local uiux_target=$(get_agent_target "uiux")
        local sre_target=$(get_agent_target "sre")

        echo "  requirements → ${requirements_target:-[エラー]}  (要件定義エージェント)"
        echo "  architect    → ${architect_target:-[エラー]}  (アーキテクチャ設計エージェント)"
        echo "  developer    → ${developer_target:-[エラー]}  (開発・実装エージェント)"
        echo "  uiux         → ${uiux_target:-[エラー]}  (UI/UXデザインエージェント)"
        echo "  sre          → ${sre_target:-[エラー]}  (SRE運用エージェント)"
    else
        echo "  requirements → [未起動]        (要件定義エージェント)"
        echo "  architect    → [未起動]        (アーキテクチャ設計エージェント)"
        echo "  developer    → [未起動]        (開発・実装エージェント)"
        echo "  uiux         → [未起動]        (UI/UXデザインエージェント)"
        echo "  sre          → [未起動]        (SRE運用エージェント)"
    fi
}

# ログ記録
log_send() {
    local agent="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p logs
    echo "[$timestamp] $agent: SENT - \"$message\"" >> logs/send_log.txt
}

# メッセージ送信
send_message() {
    local target="$1"
    local message="$2"
    
    echo "📤 送信中: $target ← '$message'"
    
    # Claude Codeのプロンプトを一度クリア
    tmux send-keys -t "$target" C-c
    sleep 0.3
    
    # メッセージ送信
    tmux send-keys -t "$target" "$message"
    sleep 0.1
    
    # エンター押下
    tmux send-keys -t "$target" C-m
    sleep 0.5
}

# ターゲット存在確認
check_target() {
    local target="$1"
    local session_name="${target%%:*}"
    
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "❌ セッション '$session_name' が見つかりません"
        return 1
    fi
    
    return 0
}

# メイン処理
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi
    
    # --listオプション
    if [[ "$1" == "--list" ]]; then
        show_agents
        exit 0
    fi
    
    if [[ $# -lt 2 ]]; then
        show_usage
        exit 1
    fi
    
    local agent_name="$1"
    local message="$2"
    
    # エージェントターゲット取得
    local target
    target=$(get_agent_target "$agent_name")
    
    if [[ -z "$target" ]]; then
        echo "❌ エラー: 不明なエージェント '$agent_name'"
        echo "利用可能エージェント: $0 --list"
        exit 1
    fi
    
    # ターゲット確認
    if ! check_target "$target"; then
        exit 1
    fi
    
    # メッセージ送信
    send_message "$target" "$message"
    
    # ログ記録
    log_send "$agent_name" "$message"
    
    echo "✅ 送信完了: $agent_name に '$message'"
    
    return 0
}

main "$@" 
#!/bin/bash

# Enterprise Agent Session 起動スクリプト

SESSION_NAME="enterprise"
WINDOW_NAME="agents"

# カラー設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏢 Enterprise Agent Session を起動しています...${NC}"

# 既存セッションの確認
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    echo -e "${YELLOW}⚠️  既存の '$SESSION_NAME' セッションが存在します${NC}"
    echo -e "既存セッションに接続しますか？ [y/N]: "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        tmux attach-session -t $SESSION_NAME
        exit 0
    else
        echo -e "${RED}❌ 処理を中止しました${NC}"
        exit 1
    fi
fi

# 新規セッション作成
tmux new-session -d -s $SESSION_NAME -n $WINDOW_NAME

# 各エージェント用のペイン作成
echo -e "${BLUE}📋 Requirements Agent を起動中...${NC}"
tmux send-keys -t $SESSION_NAME:$WINDOW_NAME.0 "cd agents/requirements && clear" C-m

echo -e "${BLUE}🏗️  Architect Agent を起動中...${NC}"
tmux split-window -t $SESSION_NAME:$WINDOW_NAME -h
tmux send-keys -t $SESSION_NAME:$WINDOW_NAME.1 "cd agents/architect && clear" C-m

echo -e "${BLUE}💻 Developer Agent を起動中...${NC}"
tmux split-window -t $SESSION_NAME:$WINDOW_NAME -v
tmux send-keys -t $SESSION_NAME:$WINDOW_NAME.2 "cd agents/developer && clear" C-m

echo -e "${BLUE}🎨 UI/UX Agent を起動中...${NC}"
tmux split-window -t $SESSION_NAME:$WINDOW_NAME.0 -v
tmux send-keys -t $SESSION_NAME:$WINDOW_NAME.3 "cd agents/uiux && clear" C-m

echo -e "${BLUE}🔧 SRE Agent を起動中...${NC}"
tmux split-window -t $SESSION_NAME:$WINDOW_NAME.2 -v
tmux send-keys -t $SESSION_NAME:$WINDOW_NAME.4 "cd agents/sre && clear" C-m

# レイアウト調整
tmux select-layout -t $SESSION_NAME:$WINDOW_NAME tiled

# 各ペインにClaude Codeを起動
echo -e "${BLUE}🤖 各エージェントでClaude Codeを起動中...${NC}"

# Requirements Agent
tmux send-keys -t $SESSION_NAME:$WINDOW_NAME.0 "echo '🔍 Requirements Agent が起動しました'" C-m
tmux send-keys -t $SESSION_NAME:$WINDOW_NAME.0 "claude" C-m

# Architect Agent
tmux send-keys -t $SESSION_NAME:$WINDOW_NAME.1 "echo '🏗️ Architect Agent が起動しました'" C-m
tmux send-keys -t $SESSION_NAME:$WINDOW_NAME.1 "claude" C-m

# Developer Agent
tmux send-keys -t $SESSION_NAME:$WINDOW_NAME.2 "echo '💻 Developer Agent が起動しました'" C-m
tmux send-keys -t $SESSION_NAME:$WINDOW_NAME.2 "claude" C-m

# UI/UX Agent
tmux send-keys -t $SESSION_NAME:$WINDOW_NAME.3 "echo '🎨 UI/UX Agent が起動しました'" C-m
tmux send-keys -t $SESSION_NAME:$WINDOW_NAME.3 "claude" C-m

# SRE Agent
tmux send-keys -t $SESSION_NAME:$WINDOW_NAME.4 "echo '🔧 SRE Agent が起動しました'" C-m
tmux send-keys -t $SESSION_NAME:$WINDOW_NAME.4 "claude" C-m

# 最初のペインを選択
tmux select-pane -t $SESSION_NAME:$WINDOW_NAME.0

echo -e "${GREEN}✅ Enterprise Agent Session が正常に起動しました！${NC}"
echo -e "${YELLOW}接続方法: tmux attach-session -t $SESSION_NAME${NC}"
echo -e "${YELLOW}メッセージ送信: ./agents/core/agent-send.sh [agent] \"[message]\"${NC}"
echo ""
echo -e "${BLUE}利用可能エージェント:${NC}"
echo -e "  requirements  - 要件定義エージェント"
echo -e "  architect     - アーキテクチャ設計エージェント"
echo -e "  developer     - 開発・実装エージェント"
echo -e "  uiux          - UI/UXデザインエージェント"
echo -e "  sre           - SRE運用エージェント"
echo ""
echo -e "${BLUE}自動で接続しますか？ [Y/n]: ${NC}"
read -r response
if [[ ! "$response" =~ ^[Nn]$ ]]; then
    tmux attach-session -t $SESSION_NAME
fi
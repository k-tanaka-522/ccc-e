#!/bin/bash
# Enterprise AI Agent Toolkit インストーラー

echo "🤖 Enterprise AI Agent Toolkit Installer"
echo "======================================"

# インストール先の確認
if [ -d ".ai-agents" ]; then
    read -p "⚠️  .ai-agents already exists. Overwrite? (y/N): " confirm
    [ "$confirm" != "y" ] && exit 1
    rm -rf .ai-agents
fi

# 現在のディレクトリからツールキットをコピー
echo "📦 Installing toolkit..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ "$SCRIPT_DIR" = "$(pwd)" ]; then
    echo "⚠️  Cannot install from the same directory. Please run from a different project directory."
    exit 1
fi

# ツールキットファイルをコピー（サブディレクトリを除く）
mkdir -p .ai-agents
cp -r "$SCRIPT_DIR"/{agents,templates,wizards,config,install.sh} .ai-agents/ 2>/dev/null || true
cp "$SCRIPT_DIR"/*.md .ai-agents/ 2>/dev/null || true

# プロジェクト固有の設定を作成
mkdir -p .ai-agents/config/project
cat > .ai-agents/config/project/settings.conf << EOF
PROJECT_NAME=$(basename $(pwd))
PROJECT_PATH=$(pwd)
CREATED_AT=$(date -I)
TOOLKIT_VERSION=1.0.0
EOF

# .gitignoreの設定
if [ -f .gitignore ]; then
    grep -q ".ai-agents/logs/" .gitignore || echo ".ai-agents/logs/" >> .gitignore
    grep -q ".ai-agents/tmp/" .gitignore || echo ".ai-agents/tmp/" >> .gitignore
else
    cat > .gitignore << EOF
.ai-agents/logs/
.ai-agents/tmp/
EOF
fi

# 実行権限の付与
chmod +x .ai-agents/wizards/*.sh 2>/dev/null || true
chmod +x .ai-agents/agents/**/*.sh 2>/dev/null || true

echo "✅ Installation completed!"
echo ""
echo "Next steps:"
echo "1. Run: .ai-agents/wizards/project-init.sh"
echo "2. Follow the wizard to set up your project"
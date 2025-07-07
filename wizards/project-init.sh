#!/bin/bash
# プロジェクト初期化ウィザード

echo "🚀 エンタープライズ開発プロジェクト初期化"
echo "=================================="

# 設定ファイルの読み込み
if [ -f "config/project/settings.conf" ]; then
    source config/project/settings.conf
fi

# モード選択
echo "実行モードを選択してください："
echo "[1] ガイドモード（推奨）- 順番に質問に答えていく"
echo "[2] おまかせモード - AIが業界標準で自動設定"
read -p "選択 (1-2): " mode

# 出力ディレクトリの作成
create_directories() {
    mkdir -p requirements architecture aws uiux
    mkdir -p logs tmp
}

# 決定事項インデックスの生成
generate_index() {
    cat > requirements/index.md << 'EOF'
# これから決めることリスト

## 1. [ ] ビジネス要件
- サービス概要
- ターゲットユーザー
- 主要機能

## 2. [ ] 技術要件
- 想定ユーザー数
- 可用性目標（SLO）
- レスポンスタイム要件

## 3. [ ] AWS構成
- 構成パターン選択
- コスト上限
- リージョン選択

## 4. [ ] 運用要件
- バックアップ頻度
- 監視項目
- アラート設定

## 操作メニュー
- [S] ステップバイステップで進める
- [A] AIにおまかせで一括設定
- [Q] 終了

EOF
}

# 決定記録の初期化
init_decision_log() {
    cat > requirements/decision_log.md << EOF
# 決定事項記録

## プロジェクト情報
- **プロジェクト名**: ${PROJECT_NAME:-"未設定"}
- **作成日**: $(date -I)
- **最終更新**: $(date -I)

## 決定事項

### $(date -I) - プロジェクト初期化
- ツールキットをインストールしました
- 基本的なディレクトリ構造を作成しました

EOF
}

# 業界テンプレートの表示
show_industry_templates() {
    echo "📋 業界別テンプレート（参考）："
    echo "1. ECサイト - 高可用性、決済システム"
    echo "2. SaaS - マルチテナント、API中心"
    echo "3. メディア - 高トラフィック、CDN"
    echo "4. 社内システム - セキュリティ重視、安定性"
    echo "5. スタートアップ - 低コスト、迅速デプロイ"
    echo "6. その他 - カスタム設定"
}

# SLOオプションの表示
show_slo_options() {
    echo "📊 可用性目標（SLO）："
    echo "1. 99.0%  - 月間7.2時間ダウン（開発環境）"
    echo "2. 99.9%  - 月間43分ダウン（本番環境・標準）"
    echo "3. 99.95% - 月間21分ダウン（重要システム）"
    echo "4. 99.99% - 月間4分ダウン（ミッションクリティカル）"
}

# AWS構成パターンの表示
show_aws_patterns() {
    echo "☁️ AWS構成パターン："
    echo "1. シンプル構成 - EC2 + RDS（低コスト）"
    echo "2. コンテナ構成 - ECS + RDS（スケーラブル）"
    echo "3. サーバーレス構成 - Lambda + DynamoDB（運用レス）"
}

# SREオプションの表示
show_sre_options() {
    echo "🔧 運用オプション："
    echo "監視レベル："
    echo "1. 基本 - CloudWatch標準メトリクス"
    echo "2. 標準 - カスタムメトリクス + アラート"
    echo "3. 高度 - X-Ray + 詳細ログ + PagerDuty"
}

# ガイドモードの実行
guide_mode() {
    echo ""
    echo "📋 ガイドモード開始"
    echo "==================="
    
    # ステップ1: ビジネス要件
    echo ""
    echo "📋 ステップ1/4: ビジネス要件"
    echo "========================="
    read -p "サービス名: " service_name
    read -p "サービス概要（1行で）: " service_desc
    
    show_industry_templates
    read -p "業界テンプレート選択 (1-6): " industry_template
    
    # ステップ2: 技術要件
    echo ""
    echo "📊 ステップ2/4: 技術要件"
    echo "====================="
    read -p "想定ユーザー数（同時接続）: " user_count
    
    show_slo_options
    read -p "可用性目標選択 (1-4): " slo_choice
    
    read -p "レスポンスタイム要件（秒）: " response_time
    
    # ステップ3: AWS構成
    echo ""
    echo "☁️ ステップ3/4: AWS構成"
    echo "====================="
    show_aws_patterns
    read -p "構成パターン選択 (1-3): " aws_pattern
    
    read -p "月額コスト上限（USD）: " cost_limit
    read -p "リージョン（例：us-east-1）: " region
    
    # ステップ4: 運用要件
    echo ""
    echo "🔧 ステップ4/4: 運用要件"
    echo "====================="
    show_sre_options
    read -p "監視レベル選択 (1-3): " monitoring_level
    
    read -p "バックアップ頻度（日）: " backup_frequency
    
    # 要件定義書の生成
    generate_requirements_guide "$service_name" "$service_desc" "$industry_template" "$user_count" "$slo_choice" "$response_time" "$aws_pattern" "$cost_limit" "$region" "$monitoring_level" "$backup_frequency"
}

# おまかせモードの実行
auto_mode() {
    echo ""
    echo "🤖 おまかせモード開始"
    echo "==================="
    
    read -p "作りたいサービスを簡単に説明してください: " description
    
    echo "AIが要件を分析中..."
    echo "（※ 実際のAI分析は今後実装予定）"
    
    # 業界標準値で自動設定
    generate_requirements_auto "$description"
}

# ガイドモード用要件定義書生成
generate_requirements_guide() {
    local service_name="$1"
    local service_desc="$2"
    local industry_template="$3"
    local user_count="$4"
    local slo_choice="$5"
    local response_time="$6"
    local aws_pattern="$7"
    local cost_limit="$8"
    local region="$9"
    local monitoring_level="${10}"
    local backup_frequency="${11}"
    
    # SLO値の変換
    local slo_percent
    case "$slo_choice" in
        1) slo_percent="99.0%" ;;
        2) slo_percent="99.9%" ;;
        3) slo_percent="99.95%" ;;
        4) slo_percent="99.99%" ;;
        *) slo_percent="99.9%" ;;
    esac
    
    cat > requirements/requirements.md << EOF
# 要件定義書

## プロジェクト概要
- **サービス名**: ${service_name}
- **概要**: ${service_desc}
- **作成日**: $(date -I)

## ビジネス要件
- **業界分類**: テンプレート${industry_template}
- **想定ユーザー数**: ${user_count}人（同時接続）

## 技術要件
- **可用性目標**: ${slo_percent}
- **レスポンスタイム**: ${response_time}秒以内
- **リージョン**: ${region}

## AWS構成
- **構成パターン**: パターン${aws_pattern}
- **コスト上限**: ${cost_limit} USD/月

## 運用要件
- **監視レベル**: レベル${monitoring_level}
- **バックアップ頻度**: ${backup_frequency}日毎

## 次のステップ
1. アーキテクチャ設計
2. CloudFormationテンプレート生成
3. コスト見積もり
4. 実装計画策定

EOF
}

# おまかせモード用要件定義書生成
generate_requirements_auto() {
    local description="$1"
    
    cat > requirements/requirements.md << EOF
# 要件定義書（自動生成）

## プロジェクト概要
- **サービス概要**: ${description}
- **作成日**: $(date -I)
- **生成方法**: AIおまかせモード

## ビジネス要件（推定）
- **業界分類**: 自動分析中
- **想定ユーザー数**: 1000人（同時接続）

## 技術要件（業界標準）
- **可用性目標**: 99.9%
- **レスポンスタイム**: 2秒以内
- **リージョン**: us-east-1

## AWS構成（推奨）
- **構成パターン**: コンテナ構成（ECS + RDS）
- **コスト上限**: 500 USD/月

## 運用要件（標準）
- **監視レベル**: 標準レベル
- **バックアップ頻度**: 1日毎

## 調整が必要な項目
- [ ] 詳細なビジネス要件の確認
- [ ] 技術要件の調整
- [ ] コスト要件の見直し

EOF
}

# メイン処理
main() {
    echo "初期化を開始します..."
    
    # ディレクトリ作成
    create_directories
    
    # 基本ファイル生成
    generate_index
    init_decision_log
    
    echo "✅ 基本セットアップ完了"
    echo ""
    
    if [ "$mode" = "1" ]; then
        guide_mode
    elif [ "$mode" = "2" ]; then
        auto_mode
    else
        echo "❌ 無効な選択です"
        exit 1
    fi
    
    echo ""
    echo "🎉 プロジェクト初期化完了！"
    echo ""
    echo "📋 生成されたファイル："
    echo "  - requirements/index.md          # これから決めることリスト"
    echo "  - requirements/decision_log.md   # 決定事項記録"
    echo "  - requirements/requirements.md   # 要件定義書"
    echo ""
    echo "📋 次のステップ："
    echo "1. requirements/index.md を確認"
    echo "2. 不足している要件があれば追加"
    echo "3. agents/requirements/agent.sh で詳細化"
    echo "4. agents/architect/agent.sh でアーキテクチャ設計"
}

# 実行
main
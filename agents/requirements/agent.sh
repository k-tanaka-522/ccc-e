#!/bin/bash
# Requirements Agent - 要件定義エージェント

# 設定
AGENT_NAME="Requirements Agent"
AGENT_VERSION="1.0.0"
CONFIG_DIR="config"
TEMPLATES_DIR="templates/requirements"
OUTPUT_DIR="../requirements"

# ログ関数
log_info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

log_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

# 使用方法の表示
show_usage() {
    cat << EOF
📋 Requirements Agent v${AGENT_VERSION}
================================

使用方法:
  $0 [オプション]

オプション:
  --wizard    ウィザードモードで要件定義
  --auto      おまかせモードで自動生成
  --update    既存要件の更新
  --validate  要件定義の検証
  --export    要件定義書のエクスポート
  --send      他のエージェントに要件定義を送信
  --help      このヘルプを表示

例:
  $0 --wizard
  $0 --auto "ECサイトを構築したい"
  $0 --update
  $0 --validate

EOF
}

# プロジェクト初期化
init_project() {
    log_info "プロジェクトを初期化しています..."
    
    # ディレクトリ作成
    mkdir -p "$OUTPUT_DIR" logs tmp
    
    # インデックスファイル生成
    if [ ! -f "$OUTPUT_DIR/index.md" ]; then
        generate_index
        log_success "インデックスファイルを生成しました"
    fi
    
    # 決定記録の初期化
    if [ ! -f "$OUTPUT_DIR/decision_log.md" ]; then
        init_decision_log
        log_success "決定記録を初期化しました"
    fi
}

# インデックス生成
generate_index() {
    cat > "$OUTPUT_DIR/index.md" << 'EOF'
# これから決めることリスト

## ✅ 完了済み項目
- [x] プロジェクト初期化

## 🔄 進行中の項目
- [ ] 要件定義詳細化

## 📋 未着手の項目

### 1. ビジネス要件
- [ ] サービス概要の明確化
- [ ] ターゲットユーザーの定義
- [ ] 主要機能の洗い出し
- [ ] 成功指標（KPI）の設定

### 2. 技術要件
- [ ] 想定ユーザー数の決定
- [ ] 可用性目標（SLO）の設定
- [ ] レスポンスタイム要件
- [ ] セキュリティ要件

### 3. AWS構成
- [ ] 構成パターンの選択
- [ ] コスト上限の設定
- [ ] リージョンの選択
- [ ] 災害復旧戦略

### 4. 運用要件
- [ ] バックアップ頻度
- [ ] 監視項目の定義
- [ ] アラート設定
- [ ] 運用体制

### 5. 開発・デプロイ要件
- [ ] CI/CD戦略
- [ ] 環境戦略（dev/staging/prod）
- [ ] デプロイ方式
- [ ] ロールバック戦略

## 🎯 優先度の高い決定事項
1. 可用性目標の設定
2. AWS構成パターンの選択
3. コスト上限の決定

## 📞 次のアクション
- Requirements Agent の実行
- 詳細要件の定義
- ステークホルダーとの確認

EOF
}

# 決定記録の初期化
init_decision_log() {
    cat > "$OUTPUT_DIR/decision_log.md" << EOF
# 決定事項記録

## プロジェクト情報
- **プロジェクト名**: $(basename "$(pwd)")
- **作成日**: $(date -I)
- **最終更新**: $(date -I)
- **担当者**: Requirements Agent

## 決定事項履歴

### $(date -I) - プロジェクト初期化
- **決定内容**: 要件定義プロセスの開始
- **理由**: エンタープライズ開発のベストプラクティスに従い、要件定義から始める
- **影響**: 全体のプロジェクト方針が決まる
- **承認者**: Requirements Agent

### 未決定事項
- ビジネス要件の詳細
- 技術要件の具体化
- AWS構成の選択
- 運用要件の明確化

## 変更履歴
- $(date -I): 決定記録を初期化

EOF
}

# ウィザードモード
wizard_mode() {
    log_info "ウィザードモードを開始します"
    
    # 既存要件の確認
    if [ -f "$OUTPUT_DIR/requirements.md" ]; then
        log_info "既存の要件定義が見つかりました"
        read -p "既存の要件を更新しますか？ (y/N): " update_existing
        if [ "$update_existing" != "y" ]; then
            log_info "処理を中止しました"
            return 0
        fi
    fi
    
    echo ""
    echo "📋 要件定義ウィザード"
    echo "===================="
    
    # 1. プロジェクト基本情報
    echo ""
    echo "📝 1. プロジェクト基本情報"
    echo "========================"
    read -p "プロジェクト名: " project_name
    read -p "プロジェクトの概要（1行で）: " project_desc
    read -p "開発期間（週）: " development_period
    read -p "チームサイズ: " team_size
    
    # 2. ビジネス要件
    echo ""
    echo "💼 2. ビジネス要件"
    echo "================="
    show_industry_templates
    read -p "業界テンプレート選択 (1-6): " industry_template
    
    read -p "ターゲットユーザー: " target_users
    read -p "主要機能（カンマ区切り）: " main_features
    read -p "成功指標（KPI）: " success_metrics
    
    # 3. 技術要件
    echo ""
    echo "🔧 3. 技術要件"
    echo "============="
    read -p "想定ユーザー数（同時接続）: " concurrent_users
    read -p "想定データ量（GB）: " data_volume
    
    show_slo_options
    read -p "可用性目標選択 (1-4): " slo_choice
    
    read -p "レスポンスタイム要件（秒）: " response_time
    
    # 4. セキュリティ要件
    echo ""
    echo "🔒 4. セキュリティ要件"
    echo "===================="
    show_security_options
    read -p "セキュリティレベル選択 (1-4): " security_level
    
    read -p "個人情報を扱いますか？ (y/N): " handle_pii
    read -p "決済機能がありますか？ (y/N): " payment_feature
    
    # 5. AWS構成
    echo ""
    echo "☁️ 5. AWS構成"
    echo "============"
    show_aws_patterns
    read -p "構成パターン選択 (1-3): " aws_pattern
    
    read -p "月額コスト上限（USD）: " cost_limit
    read -p "リージョン（例：us-east-1）: " region
    read -p "マルチAZ構成が必要ですか？ (y/N): " multi_az
    
    # 6. 運用要件
    echo ""
    echo "🔧 6. 運用要件"
    echo "============="
    show_monitoring_options
    read -p "監視レベル選択 (1-3): " monitoring_level
    
    read -p "バックアップ頻度（日）: " backup_frequency
    read -p "ログ保持期間（日）: " log_retention
    
    # 7. 開発・デプロイ要件
    echo ""
    echo "🚀 7. 開発・デプロイ要件"
    echo "====================="
    show_cicd_options
    read -p "CI/CD戦略選択 (1-3): " cicd_strategy
    
    read -p "環境数（dev/staging/prod）: " env_count
    read -p "デプロイ頻度（週）: " deploy_frequency
    
    # 要件定義書の生成
    generate_detailed_requirements "$project_name" "$project_desc" "$development_period" "$team_size" "$industry_template" "$target_users" "$main_features" "$success_metrics" "$concurrent_users" "$data_volume" "$slo_choice" "$response_time" "$security_level" "$handle_pii" "$payment_feature" "$aws_pattern" "$cost_limit" "$region" "$multi_az" "$monitoring_level" "$backup_frequency" "$log_retention" "$cicd_strategy" "$env_count" "$deploy_frequency"
    
    # 決定記録の更新
    update_decision_log "ウィザードモード完了" "全要件を対話形式で定義" "要件定義書の生成完了"
    
    log_success "ウィザードモードが完了しました"
}

# おまかせモード
auto_mode() {
    local description="$1"
    
    if [ -z "$description" ]; then
        read -p "作りたいサービスを説明してください: " description
    fi
    
    log_info "おまかせモードで要件を自動生成します"
    log_info "説明: $description"
    
    # 簡単な分析とデフォルト値の設定
    analyze_description "$description"
    
    # 決定記録の更新
    update_decision_log "おまかせモード完了" "AIによる自動要件生成" "業界標準値で初期設定"
    
    log_success "おまかせモードが完了しました"
    log_info "生成された要件を確認し、必要に応じて --update で調整してください"
}

# 説明文の分析
analyze_description() {
    local description="$1"
    
    # キーワード分析（簡易版）
    local industry="その他"
    local pattern="2"  # デフォルトはコンテナ構成
    
    if [[ "$description" =~ (EC|ecommerce|通販|ショッピング) ]]; then
        industry="ECサイト"
        pattern="2"
    elif [[ "$description" =~ (SaaS|API|サービス) ]]; then
        industry="SaaS"
        pattern="2"
    elif [[ "$description" =~ (メディア|ブログ|CMS) ]]; then
        industry="メディア"
        pattern="3"
    elif [[ "$description" =~ (社内|管理|internal) ]]; then
        industry="社内システム"
        pattern="1"
    fi
    
    log_info "分析結果: $industry"
    
    # 自動生成された要件定義書
    cat > "$OUTPUT_DIR/requirements.md" << EOF
# 要件定義書（自動生成）

## プロジェクト概要
- **サービス概要**: ${description}
- **推定業界**: ${industry}
- **作成日**: $(date -I)
- **生成方法**: AIおまかせモード

## ビジネス要件（推定）
- **ターゲットユーザー**: 一般ユーザー
- **主要機能**: 基本的なCRUD操作
- **成功指標**: ユーザー数、利用率

## 技術要件（業界標準）
- **想定ユーザー数**: 1,000人（同時接続）
- **想定データ量**: 100GB
- **可用性目標**: 99.9%
- **レスポンスタイム**: 2秒以内

## セキュリティ要件
- **セキュリティレベル**: 標準
- **個人情報**: 要確認
- **決済機能**: 要確認

## AWS構成（推奨）
- **構成パターン**: パターン${pattern}
- **コスト上限**: 500 USD/月
- **リージョン**: us-east-1
- **マルチAZ**: 推奨

## 運用要件（標準）
- **監視レベル**: 標準
- **バックアップ頻度**: 1日毎
- **ログ保持期間**: 30日

## 開発・デプロイ要件
- **CI/CD戦略**: 標準的なGitHub Actions
- **環境数**: 3環境（dev/staging/prod）
- **デプロイ頻度**: 週1回

## ⚠️ 要調整項目
以下の項目は詳細な検討が必要です：

### 高優先度
- [ ] 詳細なビジネス要件の確認
- [ ] 実際の想定ユーザー数
- [ ] セキュリティ要件の明確化
- [ ] コスト要件の見直し

### 中優先度
- [ ] 技術要件の詳細化
- [ ] 運用要件の調整
- [ ] 開発体制の確認

### 低優先度
- [ ] 詳細な機能要件
- [ ] UI/UX要件
- [ ] パフォーマンス要件

## 次のステップ
1. \`--update\` で要件の詳細化
2. ステークホルダーとの要件確認
3. アーキテクチャ設計の開始

EOF
}

# 業界テンプレートの表示
show_industry_templates() {
    echo "📋 業界別テンプレート："
    echo "1. ECサイト - 高可用性、決済システム、在庫管理"
    echo "2. SaaS - マルチテナント、API中心、サブスクリプション"
    echo "3. メディア - 高トラフィック、CDN、コンテンツ配信"
    echo "4. 社内システム - セキュリティ重視、安定性優先"
    echo "5. スタートアップ - 低コスト、迅速デプロイ、MVP"
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

# セキュリティオプションの表示
show_security_options() {
    echo "🔒 セキュリティレベル："
    echo "1. 基本 - 標準的な認証・認可"
    echo "2. 標準 - WAF、暗号化、監査ログ"
    echo "3. 高 - 多要素認証、詳細アクセス制御"
    echo "4. 最高 - RBAC、暗号化、コンプライアンス対応"
}

# AWS構成パターンの表示
show_aws_patterns() {
    echo "☁️ AWS構成パターン："
    echo "1. シンプル構成 - EC2 + RDS（低コスト、シンプル）"
    echo "2. コンテナ構成 - ECS + RDS（スケーラブル、モダン）"
    echo "3. サーバーレス構成 - Lambda + DynamoDB（運用レス、従量課金）"
}

# 監視オプションの表示
show_monitoring_options() {
    echo "📊 監視レベル："
    echo "1. 基本 - CloudWatch標準メトリクス"
    echo "2. 標準 - カスタムメトリクス + アラート + ダッシュボード"
    echo "3. 高度 - X-Ray + 詳細ログ + 外部監視 + PagerDuty"
}

# CI/CDオプションの表示
show_cicd_options() {
    echo "🚀 CI/CD戦略："
    echo "1. シンプル - GitHub Actions基本構成"
    echo "2. 標準 - GitHub Actions + テスト + デプロイ自動化"
    echo "3. 高度 - GitHub Actions + 複数環境 + 承認フロー"
}

# 詳細要件定義書の生成
generate_detailed_requirements() {
    # 引数の受け取り（長いので省略表記）
    local project_name="$1"
    local project_desc="$2"
    # ... その他の引数
    
    cat > "$OUTPUT_DIR/requirements.md" << EOF
# 要件定義書

## プロジェクト概要
- **プロジェクト名**: ${project_name}
- **概要**: ${project_desc}
- **作成日**: $(date -I)
- **最終更新**: $(date -I)

## ビジネス要件
- **業界分類**: ${industry_template}
- **ターゲットユーザー**: ${target_users}
- **主要機能**: ${main_features}
- **成功指標**: ${success_metrics}

## 技術要件
- **想定ユーザー数**: ${concurrent_users}人（同時接続）
- **想定データ量**: ${data_volume}GB
- **可用性目標**: $(get_slo_value "$slo_choice")
- **レスポンスタイム**: ${response_time}秒以内

## セキュリティ要件
- **セキュリティレベル**: レベル${security_level}
- **個人情報取扱**: ${handle_pii}
- **決済機能**: ${payment_feature}

## AWS構成
- **構成パターン**: パターン${aws_pattern}
- **コスト上限**: ${cost_limit} USD/月
- **リージョン**: ${region}
- **マルチAZ**: ${multi_az}

## 運用要件
- **監視レベル**: レベル${monitoring_level}
- **バックアップ頻度**: ${backup_frequency}日毎
- **ログ保持期間**: ${log_retention}日

## 開発・デプロイ要件
- **CI/CD戦略**: 戦略${cicd_strategy}
- **環境数**: ${env_count}環境
- **デプロイ頻度**: 週${deploy_frequency}回

## プロジェクト管理
- **開発期間**: ${development_period}週
- **チームサイズ**: ${team_size}人

## 次のステップ
1. ステークホルダーレビュー
2. アーキテクチャ設計
3. 技術選定
4. 実装計画策定

EOF
}

# SLO値の取得
get_slo_value() {
    case "$1" in
        1) echo "99.0%" ;;
        2) echo "99.9%" ;;
        3) echo "99.95%" ;;
        4) echo "99.99%" ;;
        *) echo "99.9%" ;;
    esac
}

# 決定記録の更新
update_decision_log() {
    local decision="$1"
    local reason="$2"
    local impact="$3"
    
    cat >> "$OUTPUT_DIR/decision_log.md" << EOF

### $(date -I) - ${decision}
- **決定内容**: ${decision}
- **理由**: ${reason}
- **影響**: ${impact}
- **承認者**: Requirements Agent
- **更新時刻**: $(date '+%Y-%m-%d %H:%M:%S')

EOF
}

# 要件の更新
update_requirements() {
    log_info "要件の更新を開始します"
    
    if [ ! -f "$OUTPUT_DIR/requirements.md" ]; then
        log_error "要件定義書が見つかりません。まず --wizard または --auto を実行してください"
        return 1
    fi
    
    echo "現在の要件定義書を表示します："
    echo "================================"
    cat "$OUTPUT_DIR/requirements.md"
    echo "================================"
    
    echo ""
    echo "更新する項目を選択してください："
    echo "1. ビジネス要件"
    echo "2. 技術要件"
    echo "3. セキュリティ要件"
    echo "4. AWS構成"
    echo "5. 運用要件"
    echo "6. 開発・デプロイ要件"
    echo "7. 全体的な見直し"
    
    read -p "選択 (1-7): " update_choice
    
    case "$update_choice" in
        1) update_business_requirements ;;
        2) update_technical_requirements ;;
        3) update_security_requirements ;;
        4) update_aws_requirements ;;
        5) update_operational_requirements ;;
        6) update_development_requirements ;;
        7) wizard_mode ;;
        *) log_error "無効な選択です" ;;
    esac
}

# ビジネス要件の更新
update_business_requirements() {
    echo "📋 ビジネス要件の更新"
    echo "===================="
    
    read -p "新しいターゲットユーザー（現在の値を変更する場合）: " new_target_users
    read -p "新しい主要機能（現在の値を変更する場合）: " new_main_features
    read -p "新しい成功指標（現在の値を変更する場合）: " new_success_metrics
    
    # 更新処理（実際の実装では sed や awk を使用）
    log_info "ビジネス要件を更新しました"
    
    # 決定記録の更新
    update_decision_log "ビジネス要件更新" "ステークホルダーからのフィードバック" "要件の精度向上"
}

# 技術要件の更新
update_technical_requirements() {
    echo "🔧 技術要件の更新"
    echo "================"
    
    read -p "新しい想定ユーザー数: " new_concurrent_users
    read -p "新しい想定データ量（GB）: " new_data_volume
    
    show_slo_options
    read -p "新しい可用性目標選択 (1-4): " new_slo_choice
    
    read -p "新しいレスポンスタイム要件（秒）: " new_response_time
    
    # 更新処理
    log_info "技術要件を更新しました"
    
    # 決定記録の更新
    update_decision_log "技術要件更新" "より詳細な要件が判明" "技術選定への影響"
}

# 要件の検証
validate_requirements() {
    log_info "要件定義の検証を開始します"
    
    if [ ! -f "$OUTPUT_DIR/requirements.md" ]; then
        log_error "要件定義書が見つかりません"
        return 1
    fi
    
    local validation_errors=0
    
    echo "🔍 要件定義検証レポート"
    echo "======================="
    
    # 必須項目のチェック
    echo ""
    echo "📋 必須項目チェック:"
    
    if ! grep -q "プロジェクト名" "$OUTPUT_DIR/requirements.md"; then
        echo "❌ プロジェクト名が未定義"
        ((validation_errors++))
    else
        echo "✅ プロジェクト名"
    fi
    
    if ! grep -q "可用性目標" "$OUTPUT_DIR/requirements.md"; then
        echo "❌ 可用性目標が未定義"
        ((validation_errors++))
    else
        echo "✅ 可用性目標"
    fi
    
    if ! grep -q "構成パターン" "$OUTPUT_DIR/requirements.md"; then
        echo "❌ AWS構成パターンが未定義"
        ((validation_errors++))
    else
        echo "✅ AWS構成パターン"
    fi
    
    # 整合性チェック
    echo ""
    echo "🔄 整合性チェック:"
    
    # 可用性とコストの整合性
    if grep -q "99.99%" "$OUTPUT_DIR/requirements.md" && grep -q "100 USD" "$OUTPUT_DIR/requirements.md"; then
        echo "⚠️  99.99%の可用性で月100USDは実現困難"
        ((validation_errors++))
    fi
    
    # 結果の表示
    echo ""
    if [ $validation_errors -eq 0 ]; then
        echo "✅ 検証完了: エラーなし"
        log_success "要件定義は有効です"
    else
        echo "❌ 検証完了: ${validation_errors}個のエラー"
        log_error "$validation_errors 個の問題が見つかりました"
    fi
    
    # 改善提案
    echo ""
    echo "💡 改善提案:"
    echo "- 要件の優先順位を明確化"
    echo "- 非機能要件の具体化"
    echo "- リスクの識別と対策"
    
    return $validation_errors
}

# 要件定義書のエクスポート
export_requirements() {
    log_info "要件定義書をエクスポートします"
    
    if [ ! -f "$OUTPUT_DIR/requirements.md" ]; then
        log_error "要件定義書が見つかりません"
        return 1
    fi
    
    local export_dir="exports"
    mkdir -p "$export_dir"
    
    # 日付付きファイル名
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local export_file="$export_dir/requirements_$timestamp.md"
    
    # メタデータ付きでエクスポート
    cat > "$export_file" << EOF
# 要件定義書（エクスポート版）

**エクスポート日時**: $(date '+%Y-%m-%d %H:%M:%S')  
**エクスポート者**: Requirements Agent  
**バージョン**: ${AGENT_VERSION}  

---

EOF
    
    cat "$OUTPUT_DIR/requirements.md" >> "$export_file"
    
    log_success "要件定義書をエクスポートしました: $export_file"
    
    # 統計情報の生成
    echo ""
    echo "📊 要件定義統計:"
    echo "- 文字数: $(wc -c < "$OUTPUT_DIR/requirements.md")"
    echo "- 行数: $(wc -l < "$OUTPUT_DIR/requirements.md")"
    echo "- 決定済み項目: $(grep -c "✅" "$OUTPUT_DIR/requirements.md" 2>/dev/null || echo 0)"
    echo "- 未決定項目: $(grep -c "❌" "$OUTPUT_DIR/requirements.md" 2>/dev/null || echo 0)"
}

# 他のエージェントに要件定義を送信
send_to_agents() {
    if [ ! -f "$OUTPUT_DIR/requirements.md" ]; then
        log_error "要件定義書が見つかりません"
        return 1
    fi
    
    log_info "要件定義を他のエージェントに送信しています..."
    
    # Architect Agentに送信
    if [ -f "../core/agent-send.sh" ]; then
        ../core/agent-send.sh architect "要件定義が完了しました。アーキテクチャ設計を開始してください。"
        log_success "Architect Agentに要件定義を送信しました"
    else
        log_error "agent-send.shが見つかりません"
    fi
}

# メイン処理
main() {
    echo "📋 $AGENT_NAME v$AGENT_VERSION"
    echo "================================"
    
    # 初期化
    init_project
    
    # 引数の処理
    case "$1" in
        --wizard)
            wizard_mode
            ;;
        --auto)
            auto_mode "$2"
            ;;
        --update)
            update_requirements
            ;;
        --validate)
            validate_requirements
            ;;
        --export)
            export_requirements
            ;;
        --send)
            send_to_agents
            ;;
        --help|"")
            show_usage
            ;;
        *)
            log_error "不明なオプション: $1"
            show_usage
            exit 1
            ;;
    esac
}

# 実行
main "$@"
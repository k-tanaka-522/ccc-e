#!/bin/bash
# SRE Agent - 運用・監視・自動化エージェント

# 設定
AGENT_NAME="SRE Agent"
AGENT_VERSION="1.0.0"
REQUIREMENTS_DIR="../requirements"
ARCHITECTURE_DIR="../architecture"
AWS_DIR="../aws"
OUTPUT_DIR="../ops"
TEMPLATES_DIR="templates/sre"

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

log_warn() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

# 使用方法の表示
show_usage() {
    cat << EOF
🔧 SRE Agent v${AGENT_VERSION}
=============================

使用方法:
  $0 [オプション]

オプション:
  --monitoring       監視設定を生成
  --alerting         アラート設定を生成
  --logging          ログ設定を生成
  --backup           バックアップ戦略を生成
  --disaster         災害復旧計画を生成
  --runbooks         ランブックを生成
  --automation       運用自動化スクリプトを生成
  --security         セキュリティ設定を生成
  --performance      パフォーマンス監視を生成
  --cost             コスト監視を生成
  --slo              SLO/SLI設定を生成
  --all              全ての運用設定を生成
  --help             このヘルプを表示

例:
  $0 --monitoring --level standard
  $0 --alerting --slo 99.9
  $0 --runbooks
  $0 --all

EOF
}

# 初期化
init_sre() {
    log_info "SRE環境を初期化しています..."
    
    # ディレクトリ作成
    mkdir -p "$OUTPUT_DIR" logs tmp
    mkdir -p "$OUTPUT_DIR"/{monitoring,alerting,logging,backup,runbooks,automation,security}
    mkdir -p "$OUTPUT_DIR/automation"/{scripts,terraform,ansible}
    
    log_success "SRE環境の初期化完了"
}

# プロジェクト情報の読み込み
load_project_info() {
    log_info "プロジェクト情報を読み込んでいます..."
    
    # 要件定義から情報を取得
    if [ -f "$REQUIREMENTS_DIR/requirements.md" ]; then
        SLO=$(grep -o "可用性目標.*[0-9]\+\.[0-9]\+%" "$REQUIREMENTS_DIR/requirements.md" | grep -o "[0-9]\+\.[0-9]\+%" | head -1)
        CONCURRENT_USERS=$(grep -o "想定ユーザー数.*[0-9]\+" "$REQUIREMENTS_DIR/requirements.md" | grep -o "[0-9]\+" | head -1)
        RESPONSE_TIME=$(grep -o "レスポンスタイム.*[0-9]\+" "$REQUIREMENTS_DIR/requirements.md" | grep -o "[0-9]\+" | head -1)
        COST_LIMIT=$(grep -o "コスト上限.*[0-9]\+" "$REQUIREMENTS_DIR/requirements.md" | grep -o "[0-9]\+" | head -1)
    fi
    
    # アーキテクチャから情報を取得
    if [ -f "$ARCHITECTURE_DIR/design.md" ]; then
        if grep -qi "serverless\|lambda" "$ARCHITECTURE_DIR/design.md"; then
            DEPLOYMENT_TYPE="serverless"
        elif grep -qi "container\|ecs\|docker" "$ARCHITECTURE_DIR/design.md"; then
            DEPLOYMENT_TYPE="container"
        else
            DEPLOYMENT_TYPE="traditional"
        fi
    fi
    
    # デフォルト値設定
    SLO=${SLO:-"99.9%"}
    CONCURRENT_USERS=${CONCURRENT_USERS:-1000}
    RESPONSE_TIME=${RESPONSE_TIME:-2}
    COST_LIMIT=${COST_LIMIT:-500}
    DEPLOYMENT_TYPE=${DEPLOYMENT_TYPE:-"traditional"}
    
    # SLOに基づく監視レベル決定
    case "$SLO" in
        "99.0%") MONITORING_LEVEL="basic" ;;
        "99.9%") MONITORING_LEVEL="standard" ;;
        "99.95%"|"99.99%") MONITORING_LEVEL="advanced" ;;
        *) MONITORING_LEVEL="standard" ;;
    esac
    
    log_success "プロジェクト情報読み込み完了"
    log_info "SLO: $SLO, 監視レベル: $MONITORING_LEVEL, デプロイ種別: $DEPLOYMENT_TYPE"
}

# 監視設定生成
generate_monitoring() {
    local level="$1"
    level=${level:-$MONITORING_LEVEL}
    
    log_info "監視設定を生成しています: $level"
    
    load_project_info
    
    # CloudWatch設定
    generate_cloudwatch_config "$level"
    
    # カスタムメトリクス
    generate_custom_metrics "$level"
    
    # ダッシュボード
    generate_dashboard_config "$level"
    
    # 監視計画書
    generate_monitoring_plan "$level"
    
    log_success "監視設定生成完了"
}

# CloudWatch設定生成
generate_cloudwatch_config() {
    local level="$1"
    
    cat > "$OUTPUT_DIR/monitoring/cloudwatch.yaml" << EOF
# CloudWatch 監視設定
AWSTemplateFormatVersion: '2010-09-09'
Description: 'CloudWatch monitoring configuration'

Parameters:
  Environment:
    Type: String
    Default: prod
  AlertEmail:
    Type: String
    Description: Email for alerts

Resources:
  # SNS Topic for alerts
  AlertTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: !Sub \${Environment}-alerts
      Subscription:
        - Protocol: email
          Endpoint: !Ref AlertEmail

  # CloudWatch Dashboard
  MonitoringDashboard:
    Type: AWS::CloudWatch::Dashboard
    Properties:
      DashboardName: !Sub \${Environment}-monitoring
      DashboardBody: !Sub |
        {
          "widgets": [
            {
              "type": "metric",
              "properties": {
                "metrics": [
                  ["AWS/ApplicationELB", "RequestCount"],
                  ["AWS/ApplicationELB", "TargetResponseTime"],
                  ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count"],
                  ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count"]
                ],
                "period": 300,
                "stat": "Sum",
                "region": "us-east-1",
                "title": "Load Balancer Metrics"
              }
            },
$(generate_additional_widgets "$level")
          ]
        }

  # Basic Alarms
$(generate_basic_alarms "$level")

$(if [ "$level" != "basic" ]; then
    echo "  # Advanced Alarms"
    generate_advanced_alarms "$level"
fi)

Outputs:
  DashboardURL:
    Description: CloudWatch Dashboard URL
    Value: !Sub "https://console.aws.amazon.com/cloudwatch/home?region=\${AWS::Region}#dashboards:name=\${MonitoringDashboard}"
EOF
}

# 基本アラーム生成
generate_basic_alarms() {
    local level="$1"
    
    cat << 'EOF'
  # High CPU Alarm
  HighCPUAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: !Sub ${Environment}-high-cpu
      AlarmDescription: High CPU utilization detected
      MetricName: CPUUtilization
      Namespace: AWS/EC2
      Statistic: Average
      Period: 300
      EvaluationPeriods: 2
      Threshold: 80
      ComparisonOperator: GreaterThanThreshold
      AlarmActions:
        - !Ref AlertTopic

  # High Memory Alarm
  HighMemoryAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: !Sub ${Environment}-high-memory
      AlarmDescription: High memory utilization detected
      MetricName: MemoryUtilization
      Namespace: CWAgent
      Statistic: Average
      Period: 300
      EvaluationPeriods: 2
      Threshold: 85
      ComparisonOperator: GreaterThanThreshold
      AlarmActions:
        - !Ref AlertTopic

  # HTTP 5xx Errors
  HTTP5xxAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: !Sub ${Environment}-http-5xx-errors
      AlarmDescription: High rate of 5xx errors
      MetricName: HTTPCode_Target_5XX_Count
      Namespace: AWS/ApplicationELB
      Statistic: Sum
      Period: 300
      EvaluationPeriods: 2
      Threshold: 10
      ComparisonOperator: GreaterThanThreshold
      AlarmActions:
        - !Ref AlertTopic
EOF
}

# アラート設定生成
generate_alerting() {
    local slo="$1"
    slo=${slo:-$SLO}
    
    log_info "アラート設定を生成しています: SLO $slo"
    
    load_project_info
    
    # アラートルール
    generate_alert_rules "$slo"
    
    # PagerDuty設定
    generate_pagerduty_config
    
    # Slack設定
    generate_slack_config
    
    # エスカレーション設定
    generate_escalation_policy "$slo"
    
    log_success "アラート設定生成完了"
}

# アラートルール生成
generate_alert_rules() {
    local slo="$1"
    
    # SLOに基づく閾値計算
    local error_budget
    case "$slo" in
        "99.0%") error_budget="1.0" ;;
        "99.9%") error_budget="0.1" ;;
        "99.95%") error_budget="0.05" ;;
        "99.99%") error_budget="0.01" ;;
        *) error_budget="0.1" ;;
    esac
    
    cat > "$OUTPUT_DIR/alerting/alert-rules.yaml" << EOF
# アラートルール設定
groups:
  - name: slo-alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > $error_budget
        for: 5m
        labels:
          severity: critical
          slo: availability
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ \$value | humanizePercentage }} which exceeds SLO of $slo"

      - alert: HighLatency
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > $RESPONSE_TIME
        for: 5m
        labels:
          severity: warning
          slo: latency
        annotations:
          summary: "High latency detected"
          description: "95th percentile latency is {{ \$value }}s which exceeds target of ${RESPONSE_TIME}s"

      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
          slo: availability
        annotations:
          summary: "Service is down"
          description: "{{ \$labels.instance }} has been down for more than 1 minute"

  - name: infrastructure-alerts
    rules:
      - alert: HighCPU
        expr: cpu_usage_percent > 80
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage"
          description: "CPU usage is {{ \$value }}% on {{ \$labels.instance }}"

      - alert: HighMemory
        expr: memory_usage_percent > 85
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Memory usage is {{ \$value }}% on {{ \$labels.instance }}"

      - alert: DiskSpaceLow
        expr: disk_free_percent < 15
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Low disk space"
          description: "Disk space is {{ \$value }}% free on {{ \$labels.instance }}"

  - name: database-alerts
    rules:
      - alert: DatabaseConnectionsHigh
        expr: database_connections_active / database_connections_max > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High database connections"
          description: "Database connection usage is {{ \$value | humanizePercentage }}"

      - alert: DatabaseSlowQueries
        expr: rate(database_slow_queries_total[5m]) > 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Slow database queries detected"
          description: "Slow query rate is {{ \$value }} per second"

  - name: cost-alerts
    rules:
      - alert: HighCost
        expr: aws_billing_estimated_charges > $COST_LIMIT
        for: 1h
        labels:
          severity: warning
        annotations:
          summary: "High AWS costs"
          description: "AWS costs are \${{ \$value }} which exceeds budget of \$$COST_LIMIT"
EOF
}

# ログ設定生成
generate_logging() {
    log_info "ログ設定を生成しています..."
    
    load_project_info
    
    # ログ収集設定
    generate_log_collection_config
    
    # ログパース設定
    generate_log_parsing_config
    
    # ログ保持ポリシー
    generate_log_retention_policy
    
    # ログアーカイブ設定
    generate_log_archive_config
    
    log_success "ログ設定生成完了"
}

# ログ収集設定生成
generate_log_collection_config() {
    case "$DEPLOYMENT_TYPE" in
        "container")
            generate_container_logging
            ;;
        "serverless")
            generate_serverless_logging
            ;;
        *)
            generate_traditional_logging
            ;;
    esac
}

# コンテナロギング設定
generate_container_logging() {
    cat > "$OUTPUT_DIR/logging/fluentd.conf" << 'EOF'
# Fluentd configuration for container logging

<source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>

<source>
  @type tail
  path /var/log/containers/*.log
  pos_file /var/log/fluentd-containers.log.pos
  tag kubernetes.*
  format json
  read_from_head true
</source>

# Parse application logs
<filter kubernetes.**>
  @type kubernetes_metadata
</filter>

<filter kubernetes.**>
  @type parser
  key_name log
  reserve_data true
  remove_key_name_field true
  <parse>
    @type multi_format
    <pattern>
      format json
    </pattern>
    <pattern>
      format none
    </pattern>
  </parse>
</filter>

# Add severity based on log level
<filter kubernetes.**>
  @type record_transformer
  <record>
    severity ${record.dig("level") == "error" ? "ERROR" : record.dig("level") == "warn" ? "WARNING" : "INFO"}
  </record>
</filter>

# Output to CloudWatch Logs
<match kubernetes.**>
  @type cloudwatch_logs
  log_group_name /aws/containerinsights/#{ENV['CLUSTER_NAME']}/application
  log_stream_name_key stream_name
  auto_create_stream true
  remove_log_stream_name_key true
  <buffer>
    flush_interval 5s
    chunk_limit_size 2m
    queued_chunks_limit_size 32
  </buffer>
</match>

# Output errors to separate stream
<match **>
  @type copy
  <store>
    @type cloudwatch_logs
    log_group_name /aws/application/logs
    log_stream_name general
    auto_create_stream true
  </store>
  <store>
    @type stdout
  </store>
</match>
EOF
}

# バックアップ戦略生成
generate_backup() {
    log_info "バックアップ戦略を生成しています..."
    
    load_project_info
    
    # バックアップ計画
    generate_backup_plan
    
    # 自動バックアップスクリプト
    generate_backup_scripts
    
    # 復元手順
    generate_restore_procedures
    
    # バックアップテスト計画
    generate_backup_testing_plan
    
    log_success "バックアップ戦略生成完了"
}

# バックアップ計画生成
generate_backup_plan() {
    cat > "$OUTPUT_DIR/backup/backup-plan.md" << EOF
# バックアップ計画

## 概要
- **SLO**: $SLO
- **RTO (Recovery Time Objective)**: $(calculate_rto "$SLO")
- **RPO (Recovery Point Objective)**: $(calculate_rpo "$SLO")

## バックアップ対象

### データベース
- **頻度**: 日次フルバックアップ + 継続的ログバックアップ
- **保持期間**: 30日間
- **暗号化**: AES-256
- **テスト頻度**: 週次

### アプリケーションファイル
- **頻度**: 日次
- **保持期間**: 7日間
- **対象**: 設定ファイル、アップロードファイル

### 設定・Infrastructure as Code
- **頻度**: 変更時（Git管理）
- **保持期間**: 無期限
- **対象**: CloudFormation、設定ファイル

## バックアップスケジュール

| 対象 | 頻度 | 時刻 | 保持期間 | 暗号化 |
|------|------|------|----------|--------|
| RDS | 日次 | 03:00 UTC | 30日 | ✅ |
| S3 | 継続的 | - | 30日 | ✅ |
| EBS | 日次 | 04:00 UTC | 7日 | ✅ |
| Config | 変更時 | - | 永続 | ✅ |

## 災害復旧シナリオ

### シナリオ1: データベース障害
- **RTO**: $(calculate_rto "$SLO")
- **RPO**: 15分
- **手順**: RDS自動フェイルオーバー

### シナリオ2: AZ障害
- **RTO**: $(calculate_rto "$SLO")  
- **RPO**: 15分
- **手順**: Multi-AZ自動切り替え

### シナリオ3: リージョン障害
- **RTO**: 4時間
- **RPO**: 1時間
- **手順**: 手動クロスリージョン復元

## 復元手順

### データベース復元
\`\`\`bash
# Point-in-time recovery
aws rds restore-db-instance-to-point-in-time \\
  --target-db-instance-identifier mydb-restored \\
  --source-db-instance-identifier mydb \\
  --restore-time 2023-01-01T12:00:00Z

# スナップショットからの復元
aws rds restore-db-instance-from-db-snapshot \\
  --db-instance-identifier mydb-restored \\
  --db-snapshot-identifier mydb-snapshot-20230101
\`\`\`

### ファイル復元
\`\`\`bash
# S3からの復元
aws s3 sync s3://backup-bucket/latest/ ./restore/

# EBSスナップショットからの復元
aws ec2 create-volume --snapshot-id snap-12345678 \\
  --availability-zone us-east-1a
\`\`\`

## テスト計画

### 週次テスト
- バックアップ完整性チェック
- 小規模復元テスト

### 月次テスト
- フル復元テスト（dev環境）
- 復旧時間測定

### 四半期テスト
- 災害復旧訓練
- クロスリージョン復元

## 監視・アラート

### バックアップ監視
- バックアップ成功/失敗
- バックアップサイズ異常
- 復元テスト結果

### アラート設定
- バックアップ失敗時: 即座にアラート
- RPO/RTO超過時: エスカレーション
- テスト失敗時: 翌営業日対応
EOF
}

# RTO計算
calculate_rto() {
    local slo="$1"
    case "$slo" in
        "99.0%") echo "4時間" ;;
        "99.9%") echo "1時間" ;;
        "99.95%") echo "30分" ;;
        "99.99%") echo "15分" ;;
        *) echo "1時間" ;;
    esac
}

# RPO計算
calculate_rpo() {
    local slo="$1"
    case "$slo" in
        "99.0%") echo "1時間" ;;
        "99.9%") echo "15分" ;;
        "99.95%") echo "5分" ;;
        "99.99%") echo "1分" ;;
        *) echo "15分" ;;
    esac
}

# ランブック生成
generate_runbooks() {
    log_info "ランブックを生成しています..."
    
    load_project_info
    
    # インシデント対応ランブック
    generate_incident_runbooks
    
    # 定期メンテナンス手順
    generate_maintenance_runbooks
    
    # トラブルシューティングガイド
    generate_troubleshooting_guide
    
    log_success "ランブック生成完了"
}

# インシデント対応ランブック
generate_incident_runbooks() {
    cat > "$OUTPUT_DIR/runbooks/incident-response.md" << 'EOF'
# インシデント対応ランブック

## 概要
システムインシデント発生時の対応手順を定義する。

## インシデント分類

### Severity 1 (Critical)
- **定義**: サービス完全停止、重大なセキュリティ侵害
- **対応時間**: 15分以内に初期対応
- **エスカレーション**: 即座にマネージャーに報告

### Severity 2 (High)
- **定義**: 機能の一部停止、重大な性能劣化
- **対応時間**: 1時間以内に初期対応
- **エスカレーション**: 2時間以内にマネージャーに報告

### Severity 3 (Medium)
- **定義**: 軽微な機能不具合、軽微な性能問題
- **対応時間**: 4時間以内に初期対応
- **エスカレーション**: 翌営業日にマネージャーに報告

## 対応フロー

### 1. インシデント検知
```mermaid
graph TD
    A[アラート受信] --> B[重要度判定]
    B --> C{Severity 1?}
    C -->|Yes| D[即座にオンコール]
    C -->|No| E[通常対応開始]
    D --> F[戦時態勢開始]
    E --> G[調査開始]
    F --> G
```

### 2. 初期対応手順

#### Step 1: 状況確認 (5分)
```bash
# サービス状態確認
curl -I https://api.example.com/health

# 主要メトリクス確認
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average

# エラーログ確認
aws logs filter-log-events \
  --log-group-name /aws/lambda/api \
  --start-time $(date -d '1 hour ago' +%s)000 \
  --filter-pattern 'ERROR'
```

#### Step 2: 影響範囲特定 (10分)
- 影響を受けているユーザー数
- 影響を受けている機能
- 地理的な影響範囲
- ダウンストリームサービスへの影響

#### Step 3: 一時的回避策 (15分)
```bash
# トラフィック制限
aws elbv2 modify-target-group \
  --target-group-arn arn:aws:elasticloadbalancing:... \
  --health-check-interval-seconds 10

# 緊急メンテナンスページ表示
aws s3 cp maintenance.html s3://cdn-bucket/index.html

# Auto Scaling調整
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name web-asg \
  --desired-capacity 10
```

### 3. 根本原因分析

#### データ収集
- システムメトリクス
- アプリケーションログ
- 外部依存関係の状態
- 最近のデプロイ履歴

#### 分析手法
1. **Timeline分析**: 問題発生前後の変更点
2. **5 Whys**: 根本原因の深掘り
3. **Fishbone diagram**: 要因の体系化

### 4. 復旧手順

#### データベース関連
```bash
# 接続数確認
aws rds describe-db-instances \
  --db-instance-identifier production-db

# スロークエリ確認
mysql -h $DB_HOST -u $DB_USER -p$DB_PASS \
  -e "SHOW PROCESSLIST;"

# 緊急時のRead Replica昇格
aws rds promote-read-replica \
  --db-instance-identifier production-db-replica
```

#### アプリケーション関連
```bash
# コンテナ再起動
aws ecs update-service \
  --cluster production \
  --service web-service \
  --force-new-deployment

# 前バージョンへのロールバック
kubectl rollout undo deployment/web-app

# キャッシュクリア
redis-cli FLUSHALL
```

### 5. 事後対応

#### インシデントレポート作成
- **概要**: 何が起きたか
- **影響**: 誰に、どの程度影響したか
- **根本原因**: なぜ起きたか
- **対応**: 何をしたか
- **改善策**: 再発防止のための施策

#### ポストモーテム実施
- 事実の整理（blame-free）
- プロセスの改善点
- 技術的な改善点
- アクションアイテムの設定

## 連絡先

### オンコール
- **Primary**: +81-90-1234-5678
- **Secondary**: +81-90-1234-5679
- **Manager**: +81-90-1234-5680

### エスカレーション
- **Level 1**: チームリード
- **Level 2**: エンジニアリングマネージャー
- **Level 3**: CTO

## ツール・リソース

### 監視ダッシュボード
- CloudWatch Dashboard: https://console.aws.amazon.com/cloudwatch/
- Grafana: https://grafana.company.com/
- PagerDuty: https://company.pagerduty.com/

### ログ・メトリクス
- CloudWatch Logs: https://console.aws.amazon.com/cloudwatch/
- Elasticsearch: https://elasticsearch.company.com/
- Jaeger Tracing: https://jaeger.company.com/

### コミュニケーション
- Slack: #incident-response
- Zoom: https://zoom.us/j/incident-room
- Status Page: https://status.company.com/
EOF
}

# 運用自動化生成
generate_automation() {
    log_info "運用自動化スクリプトを生成しています..."
    
    load_project_info
    
    # デプロイ自動化
    generate_deployment_automation
    
    # スケーリング自動化
    generate_scaling_automation
    
    # 定期メンテナンス自動化
    generate_maintenance_automation
    
    # 障害復旧自動化
    generate_recovery_automation
    
    log_success "運用自動化生成完了"
}

# スケーリング自動化
generate_scaling_automation() {
    cat > "$OUTPUT_DIR/automation/scripts/auto-scaling.sh" << 'EOF'
#!/bin/bash
# Auto Scaling 自動化スクリプト

set -euo pipefail

# 設定
ASG_NAME="web-app-asg"
MIN_SIZE=2
MAX_SIZE=20
TARGET_CPU=70
SCALE_UP_COOLDOWN=300
SCALE_DOWN_COOLDOWN=300

# ログ関数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# メトリクス取得
get_cpu_utilization() {
    aws cloudwatch get-metric-statistics \
        --namespace AWS/EC2 \
        --metric-name CPUUtilization \
        --dimensions Name=AutoScalingGroupName,Value=$ASG_NAME \
        --start-time $(date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%S) \
        --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
        --period 300 \
        --statistics Average \
        --query 'Datapoints[0].Average' \
        --output text
}

# 現在のキャパシティ取得
get_current_capacity() {
    aws autoscaling describe-auto-scaling-groups \
        --auto-scaling-group-names $ASG_NAME \
        --query 'AutoScalingGroups[0].DesiredCapacity' \
        --output text
}

# スケールアップ
scale_up() {
    local current_capacity=$1
    local new_capacity=$((current_capacity + 2))
    
    if [ $new_capacity -gt $MAX_SIZE ]; then
        new_capacity=$MAX_SIZE
    fi
    
    log "Scaling up from $current_capacity to $new_capacity"
    
    aws autoscaling set-desired-capacity \
        --auto-scaling-group-name $ASG_NAME \
        --desired-capacity $new_capacity \
        --honor-cooldown
}

# スケールダウン
scale_down() {
    local current_capacity=$1
    local new_capacity=$((current_capacity - 1))
    
    if [ $new_capacity -lt $MIN_SIZE ]; then
        new_capacity=$MIN_SIZE
    fi
    
    log "Scaling down from $current_capacity to $new_capacity"
    
    aws autoscaling set-desired-capacity \
        --auto-scaling-group-name $ASG_NAME \
        --desired-capacity $new_capacity \
        --honor-cooldown
}

# メイン処理
main() {
    log "Starting auto-scaling check"
    
    local cpu_util=$(get_cpu_utilization)
    local current_capacity=$(get_current_capacity)
    
    log "Current CPU utilization: ${cpu_util}%"
    log "Current capacity: $current_capacity"
    
    if (( $(echo "$cpu_util > 80" | bc -l) )); then
        log "High CPU detected, scaling up"
        scale_up $current_capacity
    elif (( $(echo "$cpu_util < 40" | bc -l) )); then
        log "Low CPU detected, scaling down"
        scale_down $current_capacity
    else
        log "CPU within normal range, no action needed"
    fi
    
    log "Auto-scaling check completed"
}

main "$@"
EOF
}

# 全運用設定生成
generate_all() {
    log_info "全ての運用設定を生成しています..."
    
    load_project_info
    
    # 各種設定を生成
    generate_monitoring "$MONITORING_LEVEL"
    generate_alerting "$SLO"
    generate_logging
    generate_backup
    generate_runbooks
    generate_automation
    
    # マスタードキュメント生成
    generate_ops_master_doc
    
    log_success "全運用設定生成完了"
}

# 運用マスタードキュメント生成
generate_ops_master_doc() {
    cat > "$OUTPUT_DIR/operations-guide.md" << EOF
# 運用ガイド

## 概要
- **プロジェクト**: $(basename "$(pwd)")
- **SLO**: $SLO
- **監視レベル**: $MONITORING_LEVEL
- **デプロイ種別**: $DEPLOYMENT_TYPE

## 生成された設定

### 監視・アラート
- [x] CloudWatch 設定
- [x] アラートルール
- [x] ダッシュボード設定
- [x] PagerDuty 統合

### ログ管理
- [x] ログ収集設定
- [x] ログパース設定
- [x] 保持ポリシー
- [x] アーカイブ設定

### バックアップ・DR
- [x] バックアップ計画
- [x] 自動バックアップスクリプト
- [x] 復元手順
- [x] 災害復旧計画

### 運用自動化
- [x] デプロイ自動化
- [x] スケーリング自動化
- [x] 定期メンテナンス
- [x] 障害復旧自動化

### ランブック
- [x] インシデント対応
- [x] トラブルシューティング
- [x] 定期メンテナンス手順

## 運用プロセス

### 日次タスク
- [ ] システム状態確認
- [ ] アラート確認・対応
- [ ] バックアップ状態確認
- [ ] コスト確認

### 週次タスク
- [ ] パフォーマンスレビュー
- [ ] セキュリティパッチ適用
- [ ] バックアップテスト
- [ ] キャパシティプランニング

### 月次タスク
- [ ] SLOレビュー
- [ ] インシデントレビュー
- [ ] コスト最適化
- [ ] 災害復旧テスト

## SLO/SLI 設定

### 可用性 SLO: $SLO
- **測定期間**: 30日間
- **エラーバジェット**: $(calculate_error_budget "$SLO")
- **アラート閾値**: エラーバジェットの50%消費時

### レスポンスタイム SLO: ${RESPONSE_TIME}秒
- **測定対象**: 95パーセンタイル
- **測定期間**: 30日間
- **アラート閾値**: SLO違反率 > 5%

## 緊急連絡先

### オンコール体制
- **平日 (9:00-18:00)**: チーム全員
- **平日夜間・休日**: オンコール担当者
- **エスカレーション**: マネージャー → CTO

### 外部ベンダー
- **AWS サポート**: [サポートケース](https://console.aws.amazon.com/support/)
- **PagerDuty**: support@pagerduty.com
- **第三者監視**: 各ベンダーサポート

## ツール・ダッシュボード

### 監視
- [CloudWatch Dashboard](https://console.aws.amazon.com/cloudwatch/)
- [Custom Dashboard](http://monitoring.company.com/)

### ログ
- [CloudWatch Logs](https://console.aws.amazon.com/cloudwatch/logs)
- [Log Analysis](http://logs.company.com/)

### アラート
- [PagerDuty](https://company.pagerduty.com/)
- [Slack #alerts](https://company.slack.com/channels/alerts)

## 改善計画

### 短期 (1-3ヶ月)
- [ ] 監視メトリクス精度向上
- [ ] アラート精度向上（ノイズ削減）
- [ ] 自動復旧スクリプト追加

### 中期 (3-6ヶ月)
- [ ] カオスエンジニアリング導入
- [ ] 予測的スケーリング実装
- [ ] 高度なログ分析

### 長期 (6-12ヶ月)
- [ ] AI/ML による異常検知
- [ ] 完全な自己修復システム
- [ ] マルチリージョン対応
EOF
}

# エラーバジェット計算
calculate_error_budget() {
    local slo="$1"
    case "$slo" in
        "99.0%") echo "1.0%" ;;
        "99.9%") echo "0.1%" ;;
        "99.95%") echo "0.05%" ;;
        "99.99%") echo "0.01%" ;;
        *) echo "0.1%" ;;
    esac
}

# メイン処理
main() {
    echo "🔧 $AGENT_NAME v$AGENT_VERSION"
    echo "============================="
    
    # 初期化
    init_sre
    
    # 引数の処理
    case "$1" in
        --monitoring)
            shift
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --level)
                        generate_monitoring "$2"
                        shift 2
                        ;;
                    *)
                        generate_monitoring
                        shift
                        ;;
                esac
            done
            ;;
        --alerting)
            shift
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --slo)
                        generate_alerting "$2"
                        shift 2
                        ;;
                    *)
                        generate_alerting
                        shift
                        ;;
                esac
            done
            ;;
        --logging)
            generate_logging
            ;;
        --backup)
            generate_backup
            ;;
        --runbooks)
            generate_runbooks
            ;;
        --automation)
            generate_automation
            ;;
        --all)
            generate_all
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
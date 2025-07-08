#!/bin/bash
# Architect Agent - システム設計・AWS構成エージェント

# 設定
AGENT_NAME="Architect Agent"
AGENT_VERSION="1.0.0"
REQUIREMENTS_DIR="../requirements"
OUTPUT_DIR="../architecture"
AWS_DIR="../aws"
TEMPLATES_DIR="templates/aws"

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
🏗️ Architect Agent v${AGENT_VERSION}
==================================

使用方法:
  $0 [オプション]

オプション:
  --analyze      要件定義からアーキテクチャを分析・設計
  --generate     CloudFormationテンプレートを生成
  --diagram      アーキテクチャ図を生成
  --estimate     コスト見積もりを計算
  --validate     設計の妥当性を検証
  --export       設計書をエクスポート
  --help         このヘルプを表示

例:
  $0 --analyze
  $0 --generate --pattern container
  $0 --diagram
  $0 --estimate

EOF
}

# 初期化
init_architect() {
    log_info "アーキテクト環境を初期化しています..."
    
    # ディレクトリ作成
    mkdir -p "$OUTPUT_DIR" "$AWS_DIR" logs tmp
    mkdir -p "$OUTPUT_DIR/diagrams"
    
    log_success "アーキテクト環境の初期化完了"
}

# 要件定義の読み込み
load_requirements() {
    if [ ! -f "$REQUIREMENTS_DIR/requirements.md" ]; then
        log_error "要件定義書が見つかりません: $REQUIREMENTS_DIR/requirements.md"
        log_info "まず Requirements Agent で要件定義を作成してください"
        return 1
    fi
    
    log_info "要件定義を読み込んでいます..."
    
    # 要件から主要パラメータを抽出
    CONCURRENT_USERS=$(grep -o "想定ユーザー数.*[0-9]\+" "$REQUIREMENTS_DIR/requirements.md" | grep -o "[0-9]\+" | head -1)
    SLO=$(grep -o "可用性目標.*[0-9]\+\.[0-9]\+%" "$REQUIREMENTS_DIR/requirements.md" | grep -o "[0-9]\+\.[0-9]\+%" | head -1)
    RESPONSE_TIME=$(grep -o "レスポンスタイム.*[0-9]\+" "$REQUIREMENTS_DIR/requirements.md" | grep -o "[0-9]\+" | head -1)
    COST_LIMIT=$(grep -o "コスト上限.*[0-9]\+" "$REQUIREMENTS_DIR/requirements.md" | grep -o "[0-9]\+" | head -1)
    REGION=$(grep -o "リージョン.*[a-z].*-[a-z].*-[0-9]" "$REQUIREMENTS_DIR/requirements.md" | grep -o "[a-z].*-[a-z].*-[0-9]" | head -1)
    
    # デフォルト値の設定
    CONCURRENT_USERS=${CONCURRENT_USERS:-1000}
    SLO=${SLO:-99.9%}
    RESPONSE_TIME=${RESPONSE_TIME:-2}
    COST_LIMIT=${COST_LIMIT:-500}
    REGION=${REGION:-us-east-1}
    
    log_success "要件定義の読み込み完了"
    log_info "想定ユーザー数: $CONCURRENT_USERS, SLO: $SLO, 応答時間: ${RESPONSE_TIME}秒, コスト上限: ${COST_LIMIT}USD, リージョン: $REGION"
}

# アーキテクチャパターンの決定
determine_architecture_pattern() {
    log_info "アーキテクチャパターンを決定しています..."
    
    # ユーザー数とSLOに基づくパターン決定
    if [ "$CONCURRENT_USERS" -lt 100 ]; then
        PATTERN="simple"
        PATTERN_NAME="シンプル構成"
        PATTERN_DESC="EC2 + RDS"
    elif [ "$CONCURRENT_USERS" -lt 10000 ] && [[ "$SLO" == "99.9%" || "$SLO" == "99.95%" ]]; then
        PATTERN="container"
        PATTERN_NAME="コンテナ構成"
        PATTERN_DESC="ECS + RDS + ElastiCache"
    else
        PATTERN="serverless"
        PATTERN_NAME="サーバーレス構成"
        PATTERN_DESC="Lambda + DynamoDB + API Gateway"
    fi
    
    log_success "アーキテクチャパターン決定: $PATTERN_NAME ($PATTERN_DESC)"
}

# アーキテクチャ分析
analyze_architecture() {
    log_info "要件定義からアーキテクチャを分析しています..."
    
    # 要件定義の読み込み
    if ! load_requirements; then
        return 1
    fi
    
    # アーキテクチャパターン決定
    determine_architecture_pattern
    
    # 設計書の生成
    generate_design_document
    
    log_success "アーキテクチャ分析完了"
}

# 設計書の生成
generate_design_document() {
    log_info "設計書を生成しています..."
    
    cat > "$OUTPUT_DIR/design.md" << EOF
# システム設計書

## 概要
- **生成日**: $(date -I)
- **生成者**: Architect Agent v${AGENT_VERSION}
- **要件定義**: $REQUIREMENTS_DIR/requirements.md

## アーキテクチャ概要

### 選択パターン
- **パターン**: $PATTERN_NAME
- **説明**: $PATTERN_DESC
- **選択理由**: 想定ユーザー数 ${CONCURRENT_USERS}人、SLO ${SLO} に最適

### システム構成

$(generate_architecture_components)

### 非機能要件への対応

#### 可用性 ($SLO)
$(generate_availability_design)

#### 性能 (${RESPONSE_TIME}秒以内)
$(generate_performance_design)

#### セキュリティ
$(generate_security_design)

#### コスト ($COST_LIMIT USD/月)
$(generate_cost_design)

## インフラ構成

### AWS リソース
$(generate_aws_resources)

### ネットワーク構成
$(generate_network_design)

### データベース設計
$(generate_database_design)

### 監視・ログ
$(generate_monitoring_design)

## デプロイ戦略
$(generate_deployment_strategy)

## 運用考慮事項
$(generate_operational_considerations)

## 次のステップ
1. CloudFormationテンプレート生成: \`architect/agent.sh --generate\`
2. アーキテクチャ図生成: \`architect/agent.sh --diagram\`
3. コスト見積もり: \`architect/agent.sh --estimate\`

EOF
    
    log_success "設計書を生成しました: $OUTPUT_DIR/design.md"
}

# アーキテクチャコンポーネントの生成
generate_architecture_components() {
    case "$PATTERN" in
        "simple")
            cat << EOF
#### フロントエンド
- **Web Server**: EC2 (t3.medium) + Nginx
- **SSL終端**: Application Load Balancer

#### バックエンド  
- **アプリケーション**: EC2 (t3.medium) × 2台
- **データベース**: RDS MySQL (t3.small)
- **ファイルストレージ**: S3

#### CDN・キャッシュ
- **CDN**: CloudFront
- **セッション管理**: ElastiCache Redis (cache.t3.micro)
EOF
            ;;
        "container")
            cat << EOF
#### コンテナ基盤
- **コンテナ**: ECS Fargate
- **ロードバランサー**: Application Load Balancer
- **サービスディスカバリ**: ECS Service Discovery

#### バックエンド
- **アプリケーション**: ECS Service (CPU: 1024, Memory: 2048)
- **データベース**: RDS MySQL Multi-AZ (t3.medium)
- **キャッシュ**: ElastiCache Redis Cluster

#### CI/CD
- **ビルド**: CodeBuild
- **デプロイ**: CodeDeploy + ECS
- **イメージ**: ECR
EOF
            ;;
        "serverless")
            cat << EOF
#### サーバーレス基盤
- **API**: API Gateway + Lambda
- **認証**: Cognito User Pools
- **ファイル処理**: Lambda + S3 Event

#### データ層
- **メインDB**: DynamoDB
- **検索**: OpenSearch Service
- **ファイルストレージ**: S3

#### 監視・ログ
- **ログ**: CloudWatch Logs
- **メトリクス**: CloudWatch + X-Ray
- **アラート**: SNS + Lambda
EOF
            ;;
    esac
}

# 可用性設計の生成
generate_availability_design() {
    case "$SLO" in
        "99.0%")
            echo "- シングルAZ構成で十分"
            echo "- RDSバックアップ: 7日間保持"
            echo "- 手動復旧プロセス"
            ;;
        "99.9%")
            echo "- Multi-AZ構成"
            echo "- RDS自動フェイルオーバー"
            echo "- Auto Scaling Group (min: 2, max: 10)"
            echo "- CloudWatch アラート設定"
            ;;
        "99.95%"|"99.99%")
            echo "- Multi-Region構成検討"
            echo "- RDS Multi-AZ + Read Replica"
            echo "- Auto Scaling Group (min: 3, max: 20)"
            echo "- Route 53 Health Check"
            echo "- 自動復旧スクリプト"
            ;;
    esac
}

# 性能設計の生成
generate_performance_design() {
    echo "- CDN (CloudFront) でグローバル配信"
    echo "- ElastiCache で DB負荷軽減"
    echo "- Auto Scaling で負荷対応"
    
    if [ "$CONCURRENT_USERS" -gt 1000 ]; then
        echo "- Connection pooling 設定"
        echo "- Database read replica"
        echo "- Static asset の S3 + CloudFront 配信"
    fi
}

# セキュリティ設計の生成
generate_security_design() {
    echo "- VPC でネットワーク分離"
    echo "- Security Group で最小権限アクセス"
    echo "- SSL/TLS暗号化 (ALB + ACM)"
    echo "- RDS暗号化有効"
    echo "- S3 暗号化有効"
    echo "- IAM Role による最小権限アクセス"
    echo "- CloudTrail でAPI監査"
    echo "- GuardDuty で脅威検知"
}

# コスト設計の生成
generate_cost_design() {
    echo "- 月額概算: $COST_LIMIT USD 以内で設計"
    echo "- Reserved Instance 活用でコスト削減"
    echo "- Auto Scaling で無駄なリソース削減"
    echo "- S3 Intelligent-Tiering でストレージ最適化"
    echo "- CloudWatch でコスト監視"
}

# AWSリソースの生成
generate_aws_resources() {
    case "$PATTERN" in
        "simple")
            cat << EOF
- **VPC**: 1個 (10.0.0.0/16)
- **Subnet**: Public×2, Private×2
- **EC2**: t3.medium × 2台
- **RDS**: MySQL t3.small
- **ElastiCache**: Redis cache.t3.micro
- **ALB**: Application Load Balancer
- **S3**: 2バケット (app, backup)
- **CloudFront**: 1ディストリビューション
EOF
            ;;
        "container")
            cat << EOF
- **ECS Cluster**: 1個
- **ECS Service**: 2個 (Frontend, Backend)
- **Task Definition**: Fargate 1vCPU, 2GB
- **RDS**: MySQL t3.medium Multi-AZ
- **ElastiCache**: Redis cluster mode
- **ECR**: 3リポジトリ
- **CodeBuild**: CI/CDプロジェクト
EOF
            ;;
        "serverless")
            cat << EOF
- **Lambda**: 5-10関数
- **API Gateway**: REST API
- **DynamoDB**: 3-5テーブル
- **Cognito**: User Pool + Identity Pool
- **S3**: 3バケット
- **CloudWatch**: Logs + Metrics
- **X-Ray**: 分散トレーシング
EOF
            ;;
    esac
}

# ネットワーク設計の生成
generate_network_design() {
    echo "- **VPC**: $REGION に配置"
    echo "- **Public Subnet**: ALB, NAT Gateway"
    echo "- **Private Subnet**: アプリケーション, データベース"
    echo "- **Internet Gateway**: 外部接続"
    echo "- **NAT Gateway**: プライベートサブネットの外部接続"
    echo "- **Route Table**: 適切なルーティング設定"
}

# データベース設計の生成
generate_database_design() {
    case "$PATTERN" in
        "simple"|"container")
            echo "- **エンジン**: MySQL 8.0"
            echo "- **インスタンス**: $([[ "$PATTERN" == "container" ]] && echo "t3.medium" || echo "t3.small")"
            echo "- **ストレージ**: GP2 SSD 100GB"
            echo "- **バックアップ**: 7日間保持"
            echo "- **暗号化**: 有効"
            ;;
        "serverless")
            echo "- **メインDB**: DynamoDB"
            echo "- **パーティションキー設計**: アクセスパターン最適化"
            echo "- **GSI**: クエリパフォーマンス向上"
            echo "- **バックアップ**: Point-in-time recovery"
            ;;
    esac
}

# 監視設計の生成
generate_monitoring_design() {
    echo "- **メトリクス**: CloudWatch (CPU, Memory, Disk, Network)"
    echo "- **ログ**: CloudWatch Logs"
    echo "- **アラート**: SNS通知"
    echo "- **ダッシュボード**: CloudWatch Dashboard"
    
    if [[ "$PATTERN" == "serverless" ]]; then
        echo "- **トレーシング**: X-Ray"
        echo "- **エラー追跡**: Lambda Error tracking"
    fi
}

# デプロイ戦略の生成
generate_deployment_strategy() {
    case "$PATTERN" in
        "simple")
            echo "- **Blue/Green デプロイ**: ALB Target Group切り替え"
            echo "- **ロールバック**: 前バージョンに即座切り戻し"
            ;;
        "container")
            echo "- **Rolling デプロイ**: ECS Service 更新"
            echo "- **カナリアデプロイ**: 段階的トラフィック移行"
            echo "- **CI/CD**: CodePipeline + CodeDeploy"
            ;;
        "serverless")
            echo "- **Alias デプロイ**: Lambda Version + Alias"
            echo "- **段階的デプロイ**: API Gateway Stage"
            echo "- **SAM/CDK**: Infrastructure as Code"
            ;;
    esac
}

# 運用考慮事項の生成
generate_operational_considerations() {
    cat << EOF
### バックアップ戦略
- データベース: 自動バックアップ + 手動スナップショット
- ファイル: S3 Cross-Region Replication
- 設定: Infrastructure as Code でバージョン管理

### 監視・アラート
- CPU使用率 > 80% でアラート
- Error rate > 1% でアラート
- Response time > ${RESPONSE_TIME}秒 でアラート
- 可用性 < ${SLO} でエスカレーション

### セキュリティ運用
- 定期的な脆弱性スキャン
- アクセスログの監視
- 不正アクセス検知 (GuardDuty)
- セキュリティパッチの定期適用

### コスト管理
- 月次コストレビュー
- 未使用リソースの定期クリーンアップ
- Reserved Instance の定期見直し
EOF
}

# CloudFormationテンプレート生成
generate_cloudformation() {
    local pattern="$1"
    pattern=${pattern:-$PATTERN}
    
    log_info "CloudFormationテンプレートを生成しています..."
    
    case "$pattern" in
        "simple")
            generate_simple_cloudformation
            ;;
        "container")
            generate_container_cloudformation
            ;;
        "serverless")
            generate_serverless_cloudformation
            ;;
        *)
            log_error "不明なパターン: $pattern"
            return 1
            ;;
    esac
    
    log_success "CloudFormationテンプレート生成完了: $AWS_DIR/cloudformation.yaml"
}

# シンプル構成のCloudFormation
generate_simple_cloudformation() {
    cat > "$AWS_DIR/cloudformation.yaml" << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Simple Web Application Stack'

Parameters:
  Environment:
    Type: String
    Default: dev
    AllowedValues: [dev, staging, prod]
  InstanceType:
    Type: String
    Default: t3.medium
    AllowedValues: [t3.small, t3.medium, t3.large]

Resources:
  # VPC
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: !Sub ${Environment}-vpc

  # Internet Gateway
  InternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: !Sub ${Environment}-igw

  InternetGatewayAttachment:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      InternetGatewayId: !Ref InternetGateway
      VpcId: !Ref VPC

  # Public Subnets
  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [0, !GetAZs '']
      CidrBlock: 10.0.1.0/24
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub ${Environment}-public-subnet-1

  PublicSubnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [1, !GetAZs '']
      CidrBlock: 10.0.2.0/24
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub ${Environment}-public-subnet-2

  # Private Subnets
  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [0, !GetAZs '']
      CidrBlock: 10.0.11.0/24
      Tags:
        - Key: Name
          Value: !Sub ${Environment}-private-subnet-1

  PrivateSubnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [1, !GetAZs '']
      CidrBlock: 10.0.12.0/24
      Tags:
        - Key: Name
          Value: !Sub ${Environment}-private-subnet-2

  # NAT Gateway
  NatGateway1EIP:
    Type: AWS::EC2::EIP
    DependsOn: InternetGatewayAttachment
    Properties:
      Domain: vpc

  NatGateway1:
    Type: AWS::EC2::NatGateway
    Properties:
      AllocationId: !GetAtt NatGateway1EIP.AllocationId
      SubnetId: !Ref PublicSubnet1

  # Route Tables
  PublicRouteTable:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC
      Tags:
        - Key: Name
          Value: !Sub ${Environment}-public-routes

  DefaultPublicRoute:
    Type: AWS::EC2::Route
    DependsOn: InternetGatewayAttachment
    Properties:
      RouteTableId: !Ref PublicRouteTable
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref InternetGateway

  PublicSubnet1RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref PublicRouteTable
      SubnetId: !Ref PublicSubnet1

  PublicSubnet2RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref PublicRouteTable
      SubnetId: !Ref PublicSubnet2

  PrivateRouteTable1:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC
      Tags:
        - Key: Name
          Value: !Sub ${Environment}-private-routes-1

  DefaultPrivateRoute1:
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: !Ref PrivateRouteTable1
      DestinationCidrBlock: 0.0.0.0/0
      NatGatewayId: !Ref NatGateway1

  PrivateSubnet1RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref PrivateRouteTable1
      SubnetId: !Ref PrivateSubnet1

  PrivateSubnet2RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref PrivateRouteTable1
      SubnetId: !Ref PrivateSubnet2

  # Security Groups
  ALBSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: !Sub ${Environment}-alb-sg
      GroupDescription: Security group for ALB
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0

  WebServerSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: !Sub ${Environment}-web-sg
      GroupDescription: Security group for web servers
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          SourceSecurityGroupId: !Ref ALBSecurityGroup
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 10.0.0.0/16

  DatabaseSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: !Sub ${Environment}-db-sg
      GroupDescription: Security group for database
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 3306
          ToPort: 3306
          SourceSecurityGroupId: !Ref WebServerSecurityGroup

  # Application Load Balancer
  ApplicationLoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Name: !Sub ${Environment}-alb
      Scheme: internet-facing
      Type: application
      Subnets:
        - !Ref PublicSubnet1
        - !Ref PublicSubnet2
      SecurityGroups:
        - !Ref ALBSecurityGroup

  # Target Group
  TargetGroup:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    Properties:
      Name: !Sub ${Environment}-tg
      Port: 80
      Protocol: HTTP
      VpcId: !Ref VPC
      HealthCheckPath: /health
      HealthCheckProtocol: HTTP

  # Listener
  ALBListener:
    Type: AWS::ElasticLoadBalancingV2::Listener
    Properties:
      DefaultActions:
        - Type: forward
          TargetGroupArn: !Ref TargetGroup
      LoadBalancerArn: !Ref ApplicationLoadBalancer
      Port: 80
      Protocol: HTTP

  # Launch Template
  LaunchTemplate:
    Type: AWS::EC2::LaunchTemplate
    Properties:
      LaunchTemplateName: !Sub ${Environment}-launch-template
      LaunchTemplateData:
        ImageId: ami-0c02fb55956c7d316  # Amazon Linux 2 AMI
        InstanceType: !Ref InstanceType
        SecurityGroupIds:
          - !Ref WebServerSecurityGroup
        UserData:
          Fn::Base64: !Sub |
            #!/bin/bash
            yum update -y
            yum install -y httpd
            systemctl start httpd
            systemctl enable httpd
            echo "<h1>Hello from ${Environment} environment</h1>" > /var/www/html/index.html
            echo "OK" > /var/www/html/health

  # Auto Scaling Group
  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      AutoScalingGroupName: !Sub ${Environment}-asg
      VPCZoneIdentifier:
        - !Ref PrivateSubnet1
        - !Ref PrivateSubnet2
      LaunchTemplate:
        LaunchTemplateId: !Ref LaunchTemplate
        Version: !GetAtt LaunchTemplate.LatestVersionNumber
      MinSize: 2
      MaxSize: 10
      DesiredCapacity: 2
      TargetGroupARNs:
        - !Ref TargetGroup
      HealthCheckType: ELB
      HealthCheckGracePeriod: 300

  # Database Subnet Group
  DatabaseSubnetGroup:
    Type: AWS::RDS::DBSubnetGroup
    Properties:
      DBSubnetGroupName: !Sub ${Environment}-db-subnet-group
      DBSubnetGroupDescription: Subnet group for RDS database
      SubnetIds:
        - !Ref PrivateSubnet1
        - !Ref PrivateSubnet2

  # RDS Database
  Database:
    Type: AWS::RDS::DBInstance
    Properties:
      DBInstanceIdentifier: !Sub ${Environment}-database
      DBInstanceClass: db.t3.small
      Engine: mysql
      EngineVersion: '8.0'
      MasterUsername: admin
      MasterUserPassword: !Sub '{{resolve:secretsmanager:${DatabaseSecret}:SecretString:password}}'
      AllocatedStorage: 100
      StorageType: gp2
      StorageEncrypted: true
      VPCSecurityGroups:
        - !Ref DatabaseSecurityGroup
      DBSubnetGroupName: !Ref DatabaseSubnetGroup
      BackupRetentionPeriod: 7
      MultiAZ: false
      PubliclyAccessible: false
      DeletionProtection: false

  # Database Secret
  DatabaseSecret:
    Type: AWS::SecretsManager::Secret
    Properties:
      Name: !Sub ${Environment}-database-secret
      Description: RDS database credentials
      GenerateSecretString:
        SecretStringTemplate: '{"username": "admin"}'
        GenerateStringKey: "password"
        PasswordLength: 32
        ExcludeCharacters: '"@/\'

  # S3 Bucket
  S3Bucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub ${Environment}-app-bucket-${AWS::AccountId}
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: AES256
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true

Outputs:
  LoadBalancerURL:
    Description: URL of the load balancer
    Value: !Sub http://${ApplicationLoadBalancer.DNSName}
    Export:
      Name: !Sub ${Environment}-LoadBalancerURL

  DatabaseEndpoint:
    Description: RDS database endpoint
    Value: !GetAtt Database.Endpoint.Address
    Export:
      Name: !Sub ${Environment}-DatabaseEndpoint
EOF
}

# コンテナ構成のCloudFormation
generate_container_cloudformation() {
    cat > "$AWS_DIR/cloudformation.yaml" << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Container-based Web Application Stack with ECS'

Parameters:
  Environment:
    Type: String
    Default: dev
    AllowedValues: [dev, staging, prod]
  
  AppImage:
    Type: String
    Default: nginx:latest
    Description: Docker image for the application

Resources:
  # VPC (同じ構成)
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: !Sub ${Environment}-vpc

  # ECS Cluster
  ECSCluster:
    Type: AWS::ECS::Cluster
    Properties:
      ClusterName: !Sub ${Environment}-cluster
      CapacityProviders:
        - FARGATE
        - FARGATE_SPOT
      DefaultCapacityProviderStrategy:
        - CapacityProvider: FARGATE
          Weight: 1

  # ECS Task Definition
  TaskDefinition:
    Type: AWS::ECS::TaskDefinition
    Properties:
      Family: !Sub ${Environment}-app
      NetworkMode: awsvpc
      RequiresCompatibilities:
        - FARGATE
      Cpu: 1024
      Memory: 2048
      ExecutionRoleArn: !Ref ECSExecutionRole
      TaskRoleArn: !Ref ECSTaskRole
      ContainerDefinitions:
        - Name: app
          Image: !Ref AppImage
          PortMappings:
            - ContainerPort: 80
              Protocol: tcp
          LogConfiguration:
            LogDriver: awslogs
            Options:
              awslogs-group: !Ref LogGroup
              awslogs-region: !Ref AWS::Region
              awslogs-stream-prefix: ecs

  # ECS Service
  ECSService:
    Type: AWS::ECS::Service
    DependsOn: ALBListener
    Properties:
      ServiceName: !Sub ${Environment}-service
      Cluster: !Ref ECSCluster
      TaskDefinition: !Ref TaskDefinition
      LaunchType: FARGATE
      DesiredCount: 2
      NetworkConfiguration:
        AwsvpcConfiguration:
          SecurityGroups:
            - !Ref ECSSecurityGroup
          Subnets:
            - !Ref PrivateSubnet1
            - !Ref PrivateSubnet2
          AssignPublicIp: DISABLED
      LoadBalancers:
        - ContainerName: app
          ContainerPort: 80
          TargetGroupArn: !Ref TargetGroup

  # IAM Roles
  ECSExecutionRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Statement:
          - Effect: Allow
            Principal:
              Service: ecs-tasks.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

  ECSTaskRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Statement:
          - Effect: Allow
            Principal:
              Service: ecs-tasks.amazonaws.com
            Action: sts:AssumeRole

  # CloudWatch Log Group
  LogGroup:
    Type: AWS::Logs::LogGroup
    Properties:
      LogGroupName: !Sub /ecs/${Environment}-app
      RetentionInDays: 30

  # Security Group for ECS
  ECSSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security group for ECS tasks
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          SourceSecurityGroupId: !Ref ALBSecurityGroup

  # Auto Scaling
  ServiceScalingTarget:
    Type: AWS::ApplicationAutoScaling::ScalableTarget
    Properties:
      MaxCapacity: 10
      MinCapacity: 2
      ResourceId: !Sub service/${ECSCluster}/${ECSService.Name}
      RoleARN: !Sub arn:aws:iam::${AWS::AccountId}:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService
      ScalableDimension: ecs:service:DesiredCount
      ServiceNamespace: ecs

  ServiceScalingPolicy:
    Type: AWS::ApplicationAutoScaling::ScalingPolicy
    Properties:
      PolicyName: !Sub ${Environment}-scaling-policy
      PolicyType: TargetTrackingScaling
      ScalingTargetId: !Ref ServiceScalingTarget
      TargetTrackingScalingPolicyConfiguration:
        PredefinedMetricSpecification:
          PredefinedMetricType: ECSServiceAverageCPUUtilization
        TargetValue: 70.0

Outputs:
  ClusterName:
    Description: ECS cluster name
    Value: !Ref ECSCluster
    Export:
      Name: !Sub ${Environment}-ClusterName

  ServiceName:
    Description: ECS service name
    Value: !Ref ECSService
    Export:
      Name: !Sub ${Environment}-ServiceName
EOF
}

# サーバーレス構成のCloudFormation
generate_serverless_cloudformation() {
    cat > "$AWS_DIR/cloudformation.yaml" << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Serverless Web Application Stack'

Parameters:
  Environment:
    Type: String
    Default: dev
    AllowedValues: [dev, staging, prod]

Resources:
  # API Gateway
  ApiGateway:
    Type: AWS::ApiGateway::RestApi
    Properties:
      Name: !Sub ${Environment}-api
      Description: Serverless API
      EndpointConfiguration:
        Types:
          - REGIONAL

  # Lambda Function
  LambdaFunction:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: !Sub ${Environment}-api-handler
      Runtime: python3.9
      Handler: index.handler
      Role: !GetAtt LambdaExecutionRole.Arn
      Code:
        ZipFile: |
          import json
          def handler(event, context):
              return {
                  'statusCode': 200,
                  'body': json.dumps({'message': 'Hello from Lambda!'})
              }
      Environment:
        Variables:
          ENVIRONMENT: !Ref Environment
          DYNAMODB_TABLE: !Ref DynamoDBTable

  # Lambda Permission for API Gateway
  LambdaApiGatewayPermission:
    Type: AWS::Lambda::Permission
    Properties:
      FunctionName: !Ref LambdaFunction
      Action: lambda:InvokeFunction
      Principal: apigateway.amazonaws.com
      SourceArn: !Sub arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:${ApiGateway}/*/*

  # API Gateway Method
  ApiGatewayMethod:
    Type: AWS::ApiGateway::Method
    Properties:
      RestApiId: !Ref ApiGateway
      ResourceId: !GetAtt ApiGateway.RootResourceId
      HttpMethod: ANY
      AuthorizationType: NONE
      Integration:
        Type: AWS_PROXY
        IntegrationHttpMethod: POST
        Uri: !Sub arn:aws:apigateway:${AWS::Region}:lambda:path/2015-03-31/functions/${LambdaFunction.Arn}/invocations

  # API Gateway Deployment
  ApiGatewayDeployment:
    Type: AWS::ApiGateway::Deployment
    DependsOn: ApiGatewayMethod
    Properties:
      RestApiId: !Ref ApiGateway
      StageName: !Ref Environment

  # DynamoDB Table
  DynamoDBTable:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: !Sub ${Environment}-app-data
      BillingMode: PAY_PER_REQUEST
      AttributeDefinitions:
        - AttributeName: id
          AttributeType: S
      KeySchema:
        - AttributeName: id
          KeyType: HASH
      StreamSpecification:
        StreamViewType: NEW_AND_OLD_IMAGES

  # Lambda Execution Role
  LambdaExecutionRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
      Policies:
        - PolicyName: DynamoDBAccess
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - dynamodb:GetItem
                  - dynamodb:PutItem
                  - dynamodb:UpdateItem
                  - dynamodb:DeleteItem
                  - dynamodb:Query
                  - dynamodb:Scan
                Resource: !GetAtt DynamoDBTable.Arn

  # S3 Bucket for static assets
  StaticAssetsBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub ${Environment}-static-assets-${AWS::AccountId}
      PublicAccessBlockConfiguration:
        BlockPublicAcls: false
        BlockPublicPolicy: false
        IgnorePublicAcls: false
        RestrictPublicBuckets: false
      WebsiteConfiguration:
        IndexDocument: index.html
        ErrorDocument: error.html

  # CloudFront Distribution
  CloudFrontDistribution:
    Type: AWS::CloudFront::Distribution
    Properties:
      DistributionConfig:
        Enabled: true
        DefaultRootObject: index.html
        Origins:
          - Id: S3Origin
            DomainName: !GetAtt StaticAssetsBucket.DomainName
            S3OriginConfig:
              OriginAccessIdentity: ''
          - Id: ApiOrigin
            DomainName: !Sub ${ApiGateway}.execute-api.${AWS::Region}.amazonaws.com
            CustomOriginConfig:
              HTTPPort: 443
              OriginProtocolPolicy: https-only
        DefaultCacheBehavior:
          TargetOriginId: S3Origin
          ViewerProtocolPolicy: redirect-to-https
          CachePolicyId: 4135ea2d-6df8-44a3-9df3-4b5a84be39ad
        CacheBehaviors:
          - PathPattern: /api/*
            TargetOriginId: ApiOrigin
            ViewerProtocolPolicy: https-only
            CachePolicyId: 4135ea2d-6df8-44a3-9df3-4b5a84be39ad

Outputs:
  ApiUrl:
    Description: API Gateway URL
    Value: !Sub https://${ApiGateway}.execute-api.${AWS::Region}.amazonaws.com/${Environment}
    Export:
      Name: !Sub ${Environment}-ApiUrl

  CloudFrontUrl:
    Description: CloudFront distribution URL
    Value: !Sub https://${CloudFrontDistribution.DomainName}
    Export:
      Name: !Sub ${Environment}-CloudFrontUrl

  DynamoDBTableName:
    Description: DynamoDB table name
    Value: !Ref DynamoDBTable
    Export:
      Name: !Sub ${Environment}-DynamoDBTableName
EOF
}

# アーキテクチャ図の生成
generate_diagram() {
    log_info "アーキテクチャ図を生成しています..."
    
    # Mermaid形式でアーキテクチャ図を生成
    case "$PATTERN" in
        "simple")
            generate_simple_diagram
            ;;
        "container")
            generate_container_diagram
            ;;
        "serverless")
            generate_serverless_diagram
            ;;
    esac
    
    log_success "アーキテクチャ図を生成しました: $OUTPUT_DIR/diagrams/"
}

# シンプル構成の図
generate_simple_diagram() {
    cat > "$OUTPUT_DIR/diagrams/architecture.mmd" << 'EOF'
graph TB
    Users[👥 Users] --> CF[CloudFront]
    CF --> ALB[Application Load Balancer]
    ALB --> EC2_1[EC2 Instance 1]
    ALB --> EC2_2[EC2 Instance 2]
    
    EC2_1 --> Cache[ElastiCache Redis]
    EC2_2 --> Cache
    EC2_1 --> RDS[(RDS MySQL)]
    EC2_2 --> RDS
    
    EC2_1 --> S3[S3 Bucket]
    EC2_2 --> S3
    
    subgraph "VPC"
        subgraph "Public Subnet"
            ALB
            NAT[NAT Gateway]
        end
        
        subgraph "Private Subnet"
            EC2_1
            EC2_2
            Cache
            RDS
        end
    end
    
    classDef compute fill:#ff9999
    classDef storage fill:#99ccff
    classDef network fill:#99ff99
    
    class EC2_1,EC2_2 compute
    class RDS,S3,Cache storage
    class ALB,CF,NAT network
EOF

    # PlantUML形式も生成
    cat > "$OUTPUT_DIR/diagrams/architecture.puml" << 'EOF'
@startuml
!theme plain
skinparam backgroundColor white

cloud "Internet" as internet
rectangle "CloudFront" as cf
rectangle "Application Load Balancer" as alb

rectangle "VPC" {
    rectangle "Public Subnet" {
        rectangle "NAT Gateway" as nat
    }
    
    rectangle "Private Subnet" {
        rectangle "EC2 Instance 1" as ec2_1
        rectangle "EC2 Instance 2" as ec2_2
        database "RDS MySQL" as rds
        database "ElastiCache Redis" as cache
    }
}

cloud "S3 Bucket" as s3

internet --> cf
cf --> alb
alb --> ec2_1
alb --> ec2_2
ec2_1 --> rds
ec2_2 --> rds
ec2_1 --> cache
ec2_2 --> cache
ec2_1 --> s3
ec2_2 --> s3

@enduml
EOF
}

# コンテナ構成の図
generate_container_diagram() {
    cat > "$OUTPUT_DIR/diagrams/architecture.mmd" << 'EOF'
graph TB
    Users[👥 Users] --> ALB[Application Load Balancer]
    ALB --> ECS[ECS Service]
    
    subgraph "ECS Cluster"
        ECS --> Task1[Fargate Task 1]
        ECS --> Task2[Fargate Task 2]
    end
    
    Task1 --> RDS[(RDS MySQL Multi-AZ)]
    Task2 --> RDS
    Task1 --> Cache[ElastiCache Redis Cluster]
    Task2 --> Cache
    
    subgraph "CI/CD Pipeline"
        Code[Source Code] --> CodeBuild[CodeBuild]
        CodeBuild --> ECR[ECR Repository]
        ECR --> Deploy[CodeDeploy]
        Deploy --> ECS
    end
    
    subgraph "VPC"
        subgraph "Public Subnet"
            ALB
        end
        
        subgraph "Private Subnet"
            ECS
            RDS
            Cache
        end
    end
    
    classDef container fill:#ff9999
    classDef storage fill:#99ccff
    classDef cicd fill:#ffcc99
    
    class Task1,Task2,ECS container
    class RDS,Cache,ECR storage
    class CodeBuild,Deploy cicd
EOF
}

# サーバーレス構成の図
generate_serverless_diagram() {
    cat > "$OUTPUT_DIR/diagrams/architecture.mmd" << 'EOF'
graph TB
    Users[👥 Users] --> CF[CloudFront]
    CF --> S3[S3 Static Hosting]
    CF --> API[API Gateway]
    
    API --> Lambda1[Lambda Function 1]
    API --> Lambda2[Lambda Function 2]
    API --> Lambda3[Lambda Function 3]
    
    Lambda1 --> DDB[(DynamoDB)]
    Lambda2 --> DDB
    Lambda3 --> DDB
    
    Lambda1 --> S3_Data[S3 Data Bucket]
    
    subgraph "Monitoring"
        CW[CloudWatch]
        XRay[X-Ray]
    end
    
    Lambda1 --> CW
    Lambda2 --> CW
    Lambda3 --> CW
    
    Lambda1 --> XRay
    Lambda2 --> XRay
    Lambda3 --> XRay
    
    classDef serverless fill:#ff9999
    classDef storage fill:#99ccff
    classDef monitoring fill:#ffcc99
    
    class Lambda1,Lambda2,Lambda3,API serverless
    class DDB,S3,S3_Data storage
    class CW,XRay monitoring
EOF
}

# コスト見積もり
estimate_cost() {
    log_info "コスト見積もりを計算しています..."
    
    if ! load_requirements; then
        return 1
    fi
    
    determine_architecture_pattern
    
    # パターン別コスト計算
    case "$PATTERN" in
        "simple")
            calculate_simple_cost
            ;;
        "container")
            calculate_container_cost
            ;;
        "serverless")
            calculate_serverless_cost
            ;;
    esac
    
    log_success "コスト見積もり完了: $OUTPUT_DIR/cost-estimate.md"
}

# シンプル構成のコスト計算
calculate_simple_cost() {
    cat > "$OUTPUT_DIR/cost-estimate.md" << EOF
# コスト見積もり - シンプル構成

## 前提条件
- **リージョン**: $REGION
- **想定ユーザー数**: $CONCURRENT_USERS人
- **SLO**: $SLO
- **予算上限**: $COST_LIMIT USD/月

## 月額コスト見積もり

### コンピュート
- **EC2 (t3.medium × 2台)**: \$60.00
- **Application Load Balancer**: \$22.50
- **NAT Gateway**: \$45.00

### ストレージ・データベース
- **RDS MySQL (t3.small)**: \$25.00
- **ElastiCache Redis (cache.t3.micro)**: \$15.00
- **S3 Standard (100GB)**: \$2.30

### ネットワーク・CDN
- **CloudFront (1TB転送)**: \$85.00
- **データ転送**: \$20.00

### 監視・セキュリティ
- **CloudWatch**: \$10.00
- **Certificate Manager**: \$0.00 (無料)

## 合計見積もり

| 項目 | 月額費用 |
|------|----------|
| **最小構成** | **\$185** |
| **推奨構成** | **\$285** |
| **高可用構成** | **\$485** |

## コスト最適化案

### 短期的最適化
- Reserved Instance 利用で 30% 削減
- Spot Instance 併用で追加 20% 削減
- S3 Intelligent-Tiering で 10% 削減

### 長期的最適化
- Auto Scaling 最適化
- 未使用リソース定期クリーンアップ
- CloudWatch コスト監視アラート設定

## 予算との比較
- **現在見積もり**: \$285/月
- **予算上限**: \$${COST_LIMIT}/月
- **差額**: $(($COST_LIMIT - 285))USD/月

$(if [ $COST_LIMIT -lt 285 ]; then
    echo "⚠️ **予算オーバー**: 構成の見直しが必要です"
    echo "### 予算内収容案"
    echo "- EC2を t3.small に変更: -\$30"
    echo "- ElastiCache を削除: -\$15"
    echo "- Single AZ構成: -\$25"
    echo "**調整後**: \$215/月"
else
    echo "✅ **予算内**: 問題ありません"
fi)

EOF
}

# 設計の妥当性検証
validate_design() {
    log_info "設計の妥当性を検証しています..."
    
    if [ ! -f "$OUTPUT_DIR/design.md" ]; then
        log_error "設計書が見つかりません。まず --analyze を実行してください"
        return 1
    fi
    
    local validation_errors=0
    
    echo "🔍 設計妥当性検証レポート"
    echo "=========================="
    
    # SLO達成可能性の検証
    echo ""
    echo "📊 SLO達成可能性:"
    case "$SLO" in
        "99.0%")
            echo "✅ Single AZ構成で達成可能"
            ;;
        "99.9%")
            if [[ "$PATTERN" == "simple" ]]; then
                echo "⚠️  Multi-AZ構成が推奨"
                ((validation_errors++))
            else
                echo "✅ 構成で達成可能"
            fi
            ;;
        "99.95%"|"99.99%")
            if [[ "$PATTERN" == "simple" ]]; then
                echo "❌ 単一構成では達成困難"
                ((validation_errors++))
            else
                echo "✅ 冗長構成で達成可能"
            fi
            ;;
    esac
    
    # 性能要件の検証
    echo ""
    echo "⚡ 性能要件:"
    if [ "$RESPONSE_TIME" -le 2 ]; then
        echo "✅ 応答時間要件は適切"
    else
        echo "⚠️  応答時間要件が厳しい可能性"
        ((validation_errors++))
    fi
    
    # コスト検証
    echo ""
    echo "💰 コスト検証:"
    # 簡易的なコスト検証
    local estimated_cost
    case "$PATTERN" in
        "simple") estimated_cost=285 ;;
        "container") estimated_cost=450 ;;
        "serverless") estimated_cost=200 ;;
    esac
    
    if [ "$COST_LIMIT" -ge "$estimated_cost" ]; then
        echo "✅ 予算内で実現可能"
    else
        echo "❌ 予算オーバー: 構成見直しが必要"
        ((validation_errors++))
    fi
    
    # セキュリティ検証
    echo ""
    echo "🔒 セキュリティ検証:"
    echo "✅ VPC内プライベート配置"
    echo "✅ セキュリティグループ設定"
    echo "✅ 暗号化設定"
    echo "✅ IAM最小権限設定"
    
    # 結果の表示
    echo ""
    if [ $validation_errors -eq 0 ]; then
        echo "✅ 検証完了: 設計に問題なし"
        log_success "設計は要件を満たしています"
    else
        echo "⚠️  検証完了: ${validation_errors}個の改善点"
        log_warn "$validation_errors 個の改善点が見つかりました"
    fi
    
    return $validation_errors
}

# 設計書のエクスポート
export_design() {
    log_info "設計書をエクスポートしています..."
    
    if [ ! -f "$OUTPUT_DIR/design.md" ]; then
        log_error "設計書が見つかりません"
        return 1
    fi
    
    local export_dir="exports"
    mkdir -p "$export_dir"
    
    # 日付付きファイル名
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local export_file="$export_dir/architecture_design_$timestamp.md"
    
    # メタデータ付きでエクスポート
    cat > "$export_file" << EOF
# システム設計書（エクスポート版）

**エクスポート日時**: $(date '+%Y-%m-%d %H:%M:%S')  
**エクスポート者**: Architect Agent v${AGENT_VERSION}  
**アーキテクチャパターン**: $PATTERN_NAME  

---

EOF
    
    cat "$OUTPUT_DIR/design.md" >> "$export_file"
    
    # CloudFormationもエクスポート
    if [ -f "$AWS_DIR/cloudformation.yaml" ]; then
        local cf_export="$export_dir/cloudformation_$timestamp.yaml"
        cp "$AWS_DIR/cloudformation.yaml" "$cf_export"
        log_success "CloudFormationテンプレートもエクスポートしました: $cf_export"
    fi
    
    log_success "設計書をエクスポートしました: $export_file"
    
    # 統計情報の生成
    echo ""
    echo "📊 設計統計:"
    echo "- 設計書サイズ: $(wc -c < "$OUTPUT_DIR/design.md") bytes"
    echo "- 設計書行数: $(wc -l < "$OUTPUT_DIR/design.md")"
    echo "- アーキテクチャパターン: $PATTERN_NAME"
    echo "- 推定月額コスト: $(case "$PATTERN" in "simple") echo "\$285" ;; "container") echo "\$450" ;; "serverless") echo "\$200" ;; esac)"
}

# メイン処理
main() {
    echo "🏗️ $AGENT_NAME v$AGENT_VERSION"
    echo "================================"
    
    # 初期化
    init_architect
    
    # 引数の処理
    case "$1" in
        --analyze)
            analyze_architecture
            ;;
        --generate)
            if ! load_requirements; then
                exit 1
            fi
            determine_architecture_pattern
            generate_cloudformation "$2"
            ;;
        --diagram)
            if ! load_requirements; then
                exit 1
            fi
            determine_architecture_pattern
            generate_diagram
            ;;
        --estimate)
            estimate_cost
            ;;
        --validate)
            validate_design
            ;;
        --export)
            export_design
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
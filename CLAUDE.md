# Enterprise AI Agent Communication System

## エージェント構成

### 🏢 Enterprise Agents (enterpriseセッション)
- **requirements** - 要件定義エージェント
- **architect** - アーキテクチャ設計エージェント  
- **developer** - 開発・実装エージェント
- **uiux** - UI/UXデザインエージェント
- **sre** - SRE運用エージェント

### 🤖 Legacy Agents (multiagentセッション)
- **boss1** - チームリーダー
- **worker1,2,3** - 実行担当

### 👑 Management (presidentセッション)
- **president** - 統括責任者

## 基本的な使用方法

### エージェントセッション起動
```bash
# Enterprise Agentセッション起動
./start-enterprise.sh

# Legacy Agentセッション起動（従来のHello World用）
./start-multiagent.sh
```

### メッセージ送信
```bash
# 個別エージェントにメッセージ送信
./agents/core/agent-send.sh [エージェント名] "[メッセージ]"

# 例：
./agents/core/agent-send.sh requirements "ECサイトの要件定義を開始"
./agents/core/agent-send.sh architect "要件に基づいて設計を実行"
./agents/core/agent-send.sh developer "実装を開始"
```

### ワークフロー実行
```bash
# 統合ワークフロー実行
./agents/core/workflow.sh [ワークフロー] "[プロジェクト説明]"

# 例：
./agents/core/workflow.sh full "ECサイトを構築したい"
./agents/core/workflow.sh requirements "社内管理システム"
```

## エージェント間通信フロー

### Enterprise Development Flow
```
requirements → architect → uiux → developer → sre
```

### Legacy Hello World Flow  
```
PRESIDENT → boss1 → workers → boss1 → PRESIDENT
```

## エージェント詳細機能

### Requirements Agent
- `--wizard` - ガイドモード要件定義
- `--auto` - 自動要件生成
- `--validate` - 要件検証
- `--send` - 他エージェントへ送信

### Architect Agent
- `--analyze` - 要件分析
- `--generate` - CloudFormation生成
- `--estimate` - コスト見積もり

### Developer Agent
- `--init` - プロジェクト初期化
- `--generate` - コード生成
- `--docker` - Docker設定生成
- `--cicd` - CI/CD設定生成

### UI/UX Agent
- `--design-system` - デザインシステム生成
- `--wireframes` - ワイヤーフレーム生成
- `--components` - UIコンポーネント生成

### SRE Agent
- `--monitoring` - 監視設定生成
- `--alerting` - アラート設定生成
- `--backup` - バックアップ計画生成
- `--runbooks` - ランブック生成

## 個人開発環境での活用

このシステムは個人開発者がエンタープライズレベルの開発プロセスを体験するためのツールです。

1. **要件定義から始める** - 曖昧な要求を明確化
2. **設計を重視する** - スケーラブルなアーキテクチャ
3. **運用を考慮する** - 監視・アラート・バックアップ
4. **ベストプラクティス** - コード品質とCI/CD
5. **コスト意識** - AWS料金を事前に把握
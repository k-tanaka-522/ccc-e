# Enterprise AI Agent Toolkit

個人開発者がエンタープライズレベルのシステムを構築できるよう支援するAIエージェントツールキットです。

**📖 Read this in other languages:** [English](README-en.md)

## 🎯 特徴

- 🎯 **要件定義から運用まで一貫した開発支援**
- ☁️ **AWS特化のアーキテクチャ自動設計**
- 🎨 **UI/UXデザインシステム生成**
- 📊 **SLO/SLI標準値の提示と選択**
- 💰 **コスト見積もり自動計算**
- 🤖 **対話型ウィザードによる設定**
- 📋 **業界別テンプレートの提供**

## 🚀 クイックスタート

### インストール

新規プロダクトのディレクトリで以下を実行：

```bash
# 方法1: 直接ダウンロード（推奨）
curl -sSL https://raw.githubusercontent.com/nishimoto265/ccc-e/main/install.sh | bash

# 方法2: リポジトリからインストール
git clone https://github.com/k-tanaka-522/ccc-e.git
cd ccc-e
./install.sh
```

### 基本的な使い方

```bash
# 1. プロジェクト初期化
.ai-agents/wizards/project-init.sh

# 2. 要件定義（ガイドモード）
.ai-agents/agents/requirements/agent.sh --wizard

# 3. 要件定義（おまかせモード）
.ai-agents/agents/requirements/agent.sh --auto "ECサイトを作りたい"

# 4. 要件の確認・更新
.ai-agents/agents/requirements/agent.sh --validate
.ai-agents/agents/requirements/agent.sh --update

# 5. 要件定義書のエクスポート
.ai-agents/agents/requirements/agent.sh --export
```

## 🤖 エージェント一覧

| エージェント | 役割 | 主要機能 |
|-------------|------|----------|
| 📋 **Requirements Agent** | 要件定義 | ウィザード、自動生成、検証 |
| 🏗️ **Architect Agent** | システム設計 | AWS構成、アーキテクチャ図 |
| 🎨 **UI/UX Agent** | デザイン設計 | デザインシステム、ワイヤーフレーム |
| 💻 **Developer Agent** | 実装支援 | コード生成、ベストプラクティス |
| 🔧 **SRE Agent** | 運用設計 | 監視、デプロイ、運用自動化 |

## 📁 生成されるファイル構造

```
your-project/
├── .ai-agents/                    # ツールキット（gitignore推奨）
├── requirements/                  # 要件定義
│   ├── index.md                  # これから決めることリスト
│   ├── decision_log.md           # 決定事項の記録
│   └── requirements.md           # 最終要件定義書
├── architecture/                 # 設計資料
│   ├── design.md                # 設計書
│   └── diagrams/                # アーキテクチャ図
├── aws/                          # AWS構成
│   └── cloudformation.yaml      # CloudFormationテンプレート
├── uiux/                         # UI/UX設計
│   ├── design-system.md         # デザインシステム
│   └── wireframes/              # ワイヤーフレーム
└── src/                          # 実際のソースコード
```

## 🎯 利用シーン

### 1. 新規プロダクト開発

```bash
# プロジェクトディレクトリ作成
mkdir my-new-product && cd my-new-product

# ツールキットインストール
curl -sSL https://raw.githubusercontent.com/nishimoto265/ccc-e/main/install.sh | bash

# 要件定義開始
.ai-agents/wizards/project-init.sh
```

### 2. 既存システムの改善

```bash
# 既存プロジェクトにツールキットを追加
./path/to/ccc-e/install.sh

# 現状分析と改善提案
.ai-agents/agents/requirements/agent.sh --auto "既存システムの改善"
```

### 3. 技術選定支援

```bash
# 要件から最適なAWS構成を提案
.ai-agents/agents/architect/agent.sh --analyze requirements/requirements.md
```

## 🔧 詳細な使用方法

### Requirements Agent（要件定義エージェント）

```bash
# 対話型ウィザード（推奨）
.ai-agents/agents/requirements/agent.sh --wizard

# AIによる自動生成
.ai-agents/agents/requirements/agent.sh --auto "作りたいシステムの説明"

# 既存要件の更新
.ai-agents/agents/requirements/agent.sh --update

# 要件定義の検証
.ai-agents/agents/requirements/agent.sh --validate

# 要件定義書のエクスポート
.ai-agents/agents/requirements/agent.sh --export
```

### ウィザードモードの詳細

ウィザードモードでは以下の項目を段階的に設定できます：

1. **プロジェクト基本情報**
   - プロジェクト名、概要
   - 開発期間、チームサイズ

2. **ビジネス要件**
   - 業界テンプレート選択
   - ターゲットユーザー
   - 主要機能、成功指標

3. **技術要件**
   - 想定ユーザー数、データ量
   - 可用性目標（SLO）
   - レスポンスタイム要件

4. **セキュリティ要件**
   - セキュリティレベル
   - 個人情報の取扱い
   - 決済機能の有無

5. **AWS構成**
   - 構成パターン選択
   - コスト上限、リージョン
   - マルチAZ構成

6. **運用要件**
   - 監視レベル
   - バックアップ頻度
   - ログ保持期間

7. **開発・デプロイ要件**
   - CI/CD戦略
   - 環境数、デプロイ頻度

## 🏗️ 業界別テンプレート

| 業界 | 特徴 | 推奨構成 |
|------|------|----------|
| **ECサイト** | 高可用性、決済システム | ECS + RDS + ElastiCache |
| **SaaS** | マルチテナント、API中心 | Lambda + DynamoDB + API Gateway |
| **メディア** | 高トラフィック、CDN | EC2 + CloudFront + S3 |
| **社内システム** | セキュリティ重視 | VPC + EC2 + RDS |
| **スタートアップ** | 低コスト、迅速デプロイ | Lambda + DynamoDB |

## 📊 SLO/SLI標準値

| 可用性 | 月間ダウンタイム | 適用場面 |
|--------|------------------|----------|
| 99.0% | 7.2時間 | 開発環境 |
| 99.9% | 43分 | 本番環境（標準） |
| 99.95% | 21分 | 重要システム |
| 99.99% | 4分 | ミッションクリティカル |

## 💰 コスト見積もり

ツールキットは選択した構成に基づいて、以下のコストパターンを提示します：

- **最小構成**: 基本的な機能のみ
- **推奨構成**: 本番運用に適した構成
- **冗長構成**: 高可用性を重視した構成

## 🛠️ カスタマイズ

### 独自テンプレートの追加

```bash
# カスタムテンプレートを追加
mkdir -p .ai-agents/templates/custom
echo "# My Custom Template" > .ai-agents/templates/custom/my-template.md
```

### エージェントの拡張

```bash
# カスタムエージェントを作成
cp .ai-agents/agents/requirements/agent.sh .ai-agents/agents/custom/my-agent.sh
# 必要に応じて編集
```

## 🔍 トラブルシューティング

### よくある問題

1. **インストールに失敗する**
   ```bash
   # 権限を確認
   chmod +x install.sh
   ./install.sh
   ```

2. **要件定義書が生成されない**
   ```bash
   # ディレクトリ権限を確認
   ls -la requirements/
   chmod -R 755 requirements/
   ```

3. **エージェントが動作しない**
   ```bash
   # 実行権限を確認
   chmod +x .ai-agents/agents/**/*.sh
   ```

### ログの確認

```bash
# エージェントのログを確認
cat .ai-agents/logs/agent.log

# 要件定義のログを確認
cat .ai-agents/logs/requirements.log
```

## 🔄 アップデート

```bash
# ツールキットの更新
cd .ai-agents
git pull origin main
chmod +x wizards/*.sh agents/**/*.sh
```

## 📚 ドキュメント

- [要件定義ガイド](docs/requirements-guide.md)
- [AWS構成パターン](docs/aws-patterns.md)
- [セキュリティベストプラクティス](docs/security-best-practices.md)
- [運用ガイド](docs/operations-guide.md)

## 🎯 今後の予定

### フェーズ2（予定）
- [ ] Architect Agent の実装
- [ ] UI/UX Agent の実装
- [ ] CloudFormation テンプレート生成
- [ ] コスト見積もり機能

### フェーズ3（予定）
- [ ] Developer Agent の実装
- [ ] SRE Agent の実装
- [ ] GitHub Actions 統合
- [ ] Web UI ダッシュボード

### 将来機能
- [ ] Figma API連携
- [ ] VS Code拡張機能
- [ ] 複数プロジェクト管理
- [ ] Claude API直接統合

## 🤝 コントリビューション

プルリクエストやIssueでのコントリビューションを歓迎いたします！

### 開発に参加する

1. このリポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチをプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

### 要望・バグ報告

- [Issues](https://github.com/k-tanaka-522/ccc-e/issues)からお気軽にご報告ください
- 新機能の提案も歓迎します

## 📄 ライセンス

このプロジェクトは[MIT License](LICENSE)の下で公開されています。

## 🙏 謝辞

このツールキットは、エンタープライズ開発の現場で培われた知見とベストプラクティスを基に構築されています。

---

🚀 **個人開発者のエンタープライズ開発を支援します！** 🤖✨

## ライセンス

MIT License

## クレジット

This project is based on [Claude-Code-Communication](https://github.com/nishimoto265/Claude-Code-Communication) by nishimoto265.

Original project is licensed under the MIT License.
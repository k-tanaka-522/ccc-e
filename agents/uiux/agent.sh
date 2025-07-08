#!/bin/bash
# UI/UX Agent - デザインシステム・UI生成エージェント

# 設定
AGENT_NAME="UI/UX Agent"
AGENT_VERSION="1.0.0"
REQUIREMENTS_DIR="../requirements"
OUTPUT_DIR="../uiux"
SRC_DIR="../src"
TEMPLATES_DIR="templates/uiux"

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
🎨 UI/UX Agent v${AGENT_VERSION}
===============================

使用方法:
  $0 [オプション]

オプション:
  --design-system    デザインシステムを生成
  --wireframes       ワイヤーフレームを生成
  --components       UIコンポーネントを生成
  --theme            テーマ・カラーパレットを生成
  --typography       タイポグラフィシステムを生成
  --icons            アイコンシステムを生成
  --responsive       レスポンシブデザイン設定を生成
  --accessibility    アクセシビリティガイドを生成
  --styleguide       スタイルガイド全体を生成
  --export           デザイン仕様書をエクスポート
  --help             このヘルプを表示

例:
  $0 --design-system --brand modern
  $0 --wireframes --type ecommerce
  $0 --components --framework react
  $0 --styleguide

EOF
}

# 初期化
init_uiux() {
    log_info "UI/UX環境を初期化しています..."
    
    # ディレクトリ作成
    mkdir -p "$OUTPUT_DIR" logs tmp
    mkdir -p "$OUTPUT_DIR"/{design-system,wireframes,components,assets,tokens}
    mkdir -p "$OUTPUT_DIR/assets"/{icons,images,fonts}
    
    log_success "UI/UX環境の初期化完了"
}

# プロジェクト情報の読み込み
load_project_info() {
    log_info "プロジェクト情報を読み込んでいます..."
    
    # 要件からプロジェクト種別を推定
    if [ -f "$REQUIREMENTS_DIR/requirements.md" ]; then
        if grep -qi "EC\|ecommerce\|ショッピング" "$REQUIREMENTS_DIR/requirements.md"; then
            PROJECT_TYPE="ecommerce"
            BRAND_STYLE="professional"
        elif grep -qi "SaaS\|API\|ダッシュボード" "$REQUIREMENTS_DIR/requirements.md"; then
            PROJECT_TYPE="saas"
            BRAND_STYLE="modern"
        elif grep -qi "メディア\|ブログ\|CMS" "$REQUIREMENTS_DIR/requirements.md"; then
            PROJECT_TYPE="media"
            BRAND_STYLE="editorial"
        elif grep -qi "社内\|管理\|internal" "$REQUIREMENTS_DIR/requirements.md"; then
            PROJECT_TYPE="enterprise"
            BRAND_STYLE="corporate"
        else
            PROJECT_TYPE="webapp"
            BRAND_STYLE="modern"
        fi
        
        # ターゲットユーザーを確認
        if grep -qi "高齢\|シニア" "$REQUIREMENTS_DIR/requirements.md"; then
            ACCESSIBILITY_LEVEL="high"
        elif grep -qi "障害\|アクセシビリティ" "$REQUIREMENTS_DIR/requirements.md"; then
            ACCESSIBILITY_LEVEL="high"
        else
            ACCESSIBILITY_LEVEL="standard"
        fi
    else
        PROJECT_TYPE="webapp"
        BRAND_STYLE="modern"
        ACCESSIBILITY_LEVEL="standard"
    fi
    
    log_success "プロジェクト情報読み込み完了"
    log_info "プロジェクト種別: $PROJECT_TYPE, ブランドスタイル: $BRAND_STYLE, アクセシビリティ: $ACCESSIBILITY_LEVEL"
}

# デザインシステム生成
generate_design_system() {
    local brand="$1"
    brand=${brand:-$BRAND_STYLE}
    
    log_info "デザインシステムを生成しています: $brand"
    
    load_project_info
    
    # メインデザインシステムファイル
    generate_design_system_docs "$brand"
    
    # デザイントークン
    generate_design_tokens "$brand"
    
    # カラーパレット
    generate_color_palette "$brand"
    
    # タイポグラフィ
    generate_typography_system
    
    # スペーシング
    generate_spacing_system
    
    log_success "デザインシステム生成完了"
}

# デザインシステムドキュメント生成
generate_design_system_docs() {
    local brand="$1"
    
    cat > "$OUTPUT_DIR/design-system.md" << EOF
# デザインシステム

## 概要
- **プロジェクト**: $(basename "$(pwd)")
- **ブランドスタイル**: $brand
- **作成日**: $(date -I)
- **作成者**: UI/UX Agent v${AGENT_VERSION}

## デザイン原則

### 1. 一貫性 (Consistency)
$(generate_consistency_principles "$brand")

### 2. アクセシビリティ (Accessibility)
$(generate_accessibility_principles)

### 3. レスポンシブデザイン
$(generate_responsive_principles)

### 4. パフォーマンス
$(generate_performance_principles)

## カラーシステム

### プライマリカラー
$(generate_primary_colors "$brand")

### セカンダリカラー
$(generate_secondary_colors "$brand")

### グレースケール
$(generate_grayscale_colors)

### セマンティックカラー
$(generate_semantic_colors)

## タイポグラフィ

### フォントファミリー
$(generate_font_families "$brand")

### 見出し (Headings)
$(generate_heading_styles)

### 本文 (Body Text)
$(generate_body_text_styles)

### その他
$(generate_other_text_styles)

## スペーシング

### スケール
$(generate_spacing_scale)

### 使用例
$(generate_spacing_examples)

## グリッドシステム

### ブレークポイント
$(generate_breakpoints)

### コンテナ
$(generate_container_specs)

### カラム
$(generate_column_specs)

## コンポーネント

### 基本コンポーネント
$(generate_basic_components_list)

### 複合コンポーネント
$(generate_complex_components_list)

## アニメーション

### トランジション
$(generate_transition_specs)

### イージング
$(generate_easing_specs)

## アイコン

### スタイル
$(generate_icon_style)

### サイズ
$(generate_icon_sizes)

### 使用ガイドライン
$(generate_icon_guidelines)

## 実装ガイド

### CSS カスタムプロパティ
\`\`\`css
$(generate_css_custom_properties "$brand")
\`\`\`

### Sass 変数
\`\`\`scss
$(generate_sass_variables "$brand")
\`\`\`

### JavaScript トークン
\`\`\`javascript
$(generate_js_tokens "$brand")
\`\`\`

## 品質基準

### アクセシビリティ
- WCAG 2.1 AA 準拠
- カラーコントラスト比: 4.5:1 以上
- キーボードナビゲーション対応

### パフォーマンス
- Core Web Vitals 対応
- モバイルファースト
- プログレッシブエンハンスメント

## メンテナンス

### 更新頻度
- 月次レビュー
- 四半期アップデート

### 変更管理
- バージョン管理
- 変更ログ記録
- チームレビュー必須

EOF
}

# 一貫性原則の生成
generate_consistency_principles() {
    local brand="$1"
    
    case "$brand" in
        "modern")
            cat << 'EOF'
- ミニマルで洗練されたデザイン
- 十分な余白を活用
- 明確な階層構造
- 一貫したインタラクション
EOF
            ;;
        "professional")
            cat << 'EOF'
- 信頼性を重視したデザイン
- 情報の明確な整理
- 機能性を最優先
- ビジネス向けの洗練性
EOF
            ;;
        "editorial")
            cat << 'EOF'
- 読みやすさを最優先
- コンテンツファーストのアプローチ
- 適切なタイポグラフィ階層
- 視覚的なストーリーテリング
EOF
            ;;
        "corporate")
            cat << 'EOF'
- 企業ブランドの一貫性
- 階層的な情報構造
- 効率性を重視
- プロフェッショナルな印象
EOF
            ;;
        *)
            cat << 'EOF'
- ユーザビリティを最優先
- 直感的なナビゲーション
- 一貫したビジュアル言語
- レスポンシブデザイン
EOF
            ;;
    esac
}

# アクセシビリティ原則の生成
generate_accessibility_principles() {
    cat << EOF
- **WCAG 2.1 AA準拠**: すべてのコンテンツがアクセシビリティ基準を満たす
- **カラーコントラスト**: 最低4.5:1のコントラスト比を維持
- **キーボードナビゲーション**: すべての機能がキーボードで操作可能
- **スクリーンリーダー対応**: 適切な見出し構造とAlt属性
- **フォーカス管理**: 明確なフォーカスインジケーター
- **エラーハンドリング**: わかりやすいエラーメッセージ

### アクセシビリティレベル: $ACCESSIBILITY_LEVEL
$(if [ "$ACCESSIBILITY_LEVEL" = "high" ]; then
    echo "- 拡大表示対応（200%まで）"
    echo "- 音声ナビゲーション対応"
    echo "- 簡易操作モード提供"
    echo "- 色覚多様性への配慮"
fi)
EOF
}

# プライマリカラー生成
generate_primary_colors() {
    local brand="$1"
    
    case "$brand" in
        "modern")
            cat << 'EOF'
```
Primary Blue:   #2563EB (rgb(37, 99, 235))
Primary Dark:   #1D4ED8 (rgb(29, 78, 216))
Primary Light:  #3B82F6 (rgb(59, 130, 246))
Primary Pale:   #DBEAFE (rgb(219, 234, 254))
```

用途:
- メインのCTA（Call to Action）
- リンクテキスト
- プライマリボタン
- アクティブ状態
EOF
            ;;
        "professional")
            cat << 'EOF'
```
Primary Navy:   #1E293B (rgb(30, 41, 59))
Primary Blue:   #0F172A (rgb(15, 23, 42))
Primary Light:  #334155 (rgb(51, 65, 85))
Primary Pale:   #F1F5F9 (rgb(241, 245, 249))
```

用途:
- メインナビゲーション
- 重要なボタン
- 見出し
- フォーカス状態
EOF
            ;;
        "editorial")
            cat << 'EOF'
```
Primary Black:  #1F2937 (rgb(31, 41, 55))
Primary Gray:   #374151 (rgb(55, 65, 81))
Primary Light:  #6B7280 (rgb(107, 114, 128))
Primary Pale:   #F9FAFB (rgb(249, 250, 251))
```

用途:
- メインテキスト
- 見出し
- ナビゲーション
- 境界線
EOF
            ;;
        *)
            cat << 'EOF'
```
Primary Blue:   #3B82F6 (rgb(59, 130, 246))
Primary Dark:   #1E40AF (rgb(30, 64, 175))
Primary Light:  #60A5FA (rgb(96, 165, 250))
Primary Pale:   #EBF4FF (rgb(235, 244, 255))
```

用途:
- メインアクション
- リンク
- フォーカス状態
- アクティブ要素
EOF
            ;;
    esac
}

# デザイントークン生成
generate_design_tokens() {
    local brand="$1"
    
    cat > "$OUTPUT_DIR/tokens/design-tokens.json" << EOF
{
  "color": {
    "primary": {
      "50": {"value": "#eff6ff"},
      "100": {"value": "#dbeafe"},
      "200": {"value": "#bfdbfe"},
      "300": {"value": "#93c5fd"},
      "400": {"value": "#60a5fa"},
      "500": {"value": "#3b82f6"},
      "600": {"value": "#2563eb"},
      "700": {"value": "#1d4ed8"},
      "800": {"value": "#1e40af"},
      "900": {"value": "#1e3a8a"}
    },
    "gray": {
      "50": {"value": "#f9fafb"},
      "100": {"value": "#f3f4f6"},
      "200": {"value": "#e5e7eb"},
      "300": {"value": "#d1d5db"},
      "400": {"value": "#9ca3af"},
      "500": {"value": "#6b7280"},
      "600": {"value": "#4b5563"},
      "700": {"value": "#374151"},
      "800": {"value": "#1f2937"},
      "900": {"value": "#111827"}
    },
    "semantic": {
      "success": {"value": "#10b981"},
      "warning": {"value": "#f59e0b"},
      "error": {"value": "#ef4444"},
      "info": {"value": "#3b82f6"}
    }
  },
  "spacing": {
    "xs": {"value": "0.25rem"},
    "sm": {"value": "0.5rem"},
    "md": {"value": "1rem"},
    "lg": {"value": "1.5rem"},
    "xl": {"value": "2rem"},
    "2xl": {"value": "3rem"},
    "3xl": {"value": "4rem"},
    "4xl": {"value": "6rem"}
  },
  "typography": {
    "fontFamily": {
      "sans": {"value": "Inter, system-ui, sans-serif"},
      "serif": {"value": "Georgia, serif"},
      "mono": {"value": "JetBrains Mono, monospace"}
    },
    "fontSize": {
      "xs": {"value": "0.75rem"},
      "sm": {"value": "0.875rem"},
      "base": {"value": "1rem"},
      "lg": {"value": "1.125rem"},
      "xl": {"value": "1.25rem"},
      "2xl": {"value": "1.5rem"},
      "3xl": {"value": "1.875rem"},
      "4xl": {"value": "2.25rem"},
      "5xl": {"value": "3rem"}
    },
    "fontWeight": {
      "light": {"value": "300"},
      "normal": {"value": "400"},
      "medium": {"value": "500"},
      "semibold": {"value": "600"},
      "bold": {"value": "700"}
    },
    "lineHeight": {
      "tight": {"value": "1.25"},
      "normal": {"value": "1.5"},
      "relaxed": {"value": "1.75"}
    }
  },
  "borderRadius": {
    "none": {"value": "0"},
    "sm": {"value": "0.125rem"},
    "md": {"value": "0.375rem"},
    "lg": {"value": "0.5rem"},
    "xl": {"value": "0.75rem"},
    "full": {"value": "9999px"}
  },
  "shadow": {
    "sm": {"value": "0 1px 2px 0 rgb(0 0 0 / 0.05)"},
    "md": {"value": "0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)"},
    "lg": {"value": "0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)"},
    "xl": {"value": "0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)"}
  }
}
EOF
}

# ワイヤーフレーム生成
generate_wireframes() {
    local type="$1"
    type=${type:-$PROJECT_TYPE}
    
    log_info "ワイヤーフレームを生成しています: $type"
    
    load_project_info
    
    mkdir -p "$OUTPUT_DIR/wireframes"
    
    case "$type" in
        "ecommerce")
            generate_ecommerce_wireframes
            ;;
        "saas")
            generate_saas_wireframes
            ;;
        "media")
            generate_media_wireframes
            ;;
        "enterprise")
            generate_enterprise_wireframes
            ;;
        *)
            generate_generic_wireframes
            ;;
    esac
    
    # 共通ワイヤーフレーム
    generate_common_wireframes
    
    log_success "ワイヤーフレーム生成完了"
}

# ECサイトワイヤーフレーム
generate_ecommerce_wireframes() {
    cat > "$OUTPUT_DIR/wireframes/homepage.md" << 'EOF'
# ホームページ - ワイヤーフレーム

## レイアウト構成

```
┌─────────────────────────────────────────┐
│ Header                                  │
│ [Logo] [Nav] [Search] [Cart] [User]    │
├─────────────────────────────────────────┤
│ Hero Section                           │
│ [Main Banner] [CTA Button]             │
├─────────────────────────────────────────┤
│ Featured Categories                    │
│ [Cat1] [Cat2] [Cat3] [Cat4]           │
├─────────────────────────────────────────┤
│ Popular Products                       │
│ [Product Grid 4x2]                     │
├─────────────────────────────────────────┤
│ Special Offers                         │
│ [Banner] [Discount Info]               │
├─────────────────────────────────────────┤
│ Footer                                 │
│ [Links] [Social] [Newsletter]          │
└─────────────────────────────────────────┘
```

## コンポーネント詳細

### Header
- ロゴ（左端）
- メインナビゲーション
- 検索バー（中央）
- カートアイコン（商品数表示）
- ユーザーメニュー

### Hero Section
- 大型バナー画像
- キャッチコピー
- 主要CTA（ボタン）

### Product Card
- 商品画像
- 商品名
- 価格（定価・セール価格）
- 評価（星）
- 「カートに追加」ボタン

## レスポンシブ考慮

### モバイル
- ハンバーガーメニュー
- 商品グリッド: 2列
- 検索バー: 折りたたみ

### タブレット
- 商品グリッド: 3列
- ナビゲーション: 一部表示

### デスクトップ
- 全要素表示
- 商品グリッド: 4列
EOF

    cat > "$OUTPUT_DIR/wireframes/product-page.md" << 'EOF'
# 商品詳細ページ - ワイヤーフレーム

## レイアウト構成

```
┌─────────────────────────────────────────┐
│ Breadcrumb                             │
│ Home > Category > Product              │
├─────────────────┬───────────────────────┤
│ Product Images  │ Product Info          │
│ [Main Image]    │ Title                 │
│ [Thumbnails]    │ Price                 │
│                 │ Rating                │
│                 │ Description           │
│                 │ [Add to Cart]         │
│                 │ [Wishlist]            │
├─────────────────┴───────────────────────┤
│ Product Details                         │
│ [Tabs: Details | Reviews | Shipping]   │
├─────────────────────────────────────────┤
│ Related Products                        │
│ [Product Grid 4x1]                     │
└─────────────────────────────────────────┘
```

## 機能要件

### 商品画像
- メイン画像表示
- サムネイル選択
- ズーム機能
- 360度ビュー（オプション）

### 商品情報
- 商品名
- 価格（定価・セール価格）
- 在庫状況
- サイズ・色選択
- 数量選択
- カートに追加
- ウィッシュリスト追加

### レビュー
- 評価表示
- レビュー一覧
- レビュー投稿

### 関連商品
- おすすめ商品
- 一緒に購入される商品
- 最近見た商品
EOF
}

# UIコンポーネント生成
generate_components() {
    local framework="$1"
    framework=${framework:-"react"}
    
    log_info "UIコンポーネントを生成しています: $framework"
    
    load_project_info
    
    mkdir -p "$OUTPUT_DIR/components"
    
    case "$framework" in
        "react")
            generate_react_components
            ;;
        "vue")
            generate_vue_components
            ;;
        "angular")
            generate_angular_components
            ;;
        *)
            log_error "サポートされていないフレームワーク: $framework"
            return 1
            ;;
    esac
    
    log_success "UIコンポーネント生成完了"
}

# React コンポーネント生成
generate_react_components() {
    # Button コンポーネント
    cat > "$OUTPUT_DIR/components/Button.jsx" << 'EOF'
import React from 'react';
import PropTypes from 'prop-types';
import './Button.css';

const Button = ({
  children,
  variant = 'primary',
  size = 'medium',
  disabled = false,
  loading = false,
  onClick,
  type = 'button',
  className = '',
  ...props
}) => {
  const baseClass = 'btn';
  const variantClass = `btn--${variant}`;
  const sizeClass = `btn--${size}`;
  const stateClass = disabled ? 'btn--disabled' : '';
  const loadingClass = loading ? 'btn--loading' : '';
  
  const classes = [
    baseClass,
    variantClass,
    sizeClass,
    stateClass,
    loadingClass,
    className
  ].filter(Boolean).join(' ');

  return (
    <button
      type={type}
      className={classes}
      disabled={disabled || loading}
      onClick={onClick}
      {...props}
    >
      {loading ? (
        <span className="btn__spinner" aria-hidden="true" />
      ) : null}
      <span className={loading ? 'btn__text--hidden' : 'btn__text'}>
        {children}
      </span>
    </button>
  );
};

Button.propTypes = {
  children: PropTypes.node.isRequired,
  variant: PropTypes.oneOf(['primary', 'secondary', 'outline', 'ghost', 'danger']),
  size: PropTypes.oneOf(['small', 'medium', 'large']),
  disabled: PropTypes.bool,
  loading: PropTypes.bool,
  onClick: PropTypes.func,
  type: PropTypes.oneOf(['button', 'submit', 'reset']),
  className: PropTypes.string,
};

export default Button;
EOF

    # Button CSS
    cat > "$OUTPUT_DIR/components/Button.css" << 'EOF'
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  border: 1px solid transparent;
  border-radius: 0.375rem;
  font-family: inherit;
  font-weight: 500;
  text-decoration: none;
  cursor: pointer;
  transition: all 0.2s ease-in-out;
  position: relative;
  overflow: hidden;
}

.btn:focus {
  outline: 2px solid var(--color-primary-500);
  outline-offset: 2px;
}

/* Variants */
.btn--primary {
  background-color: var(--color-primary-600);
  color: white;
  border-color: var(--color-primary-600);
}

.btn--primary:hover:not(.btn--disabled) {
  background-color: var(--color-primary-700);
  border-color: var(--color-primary-700);
}

.btn--secondary {
  background-color: var(--color-gray-600);
  color: white;
  border-color: var(--color-gray-600);
}

.btn--secondary:hover:not(.btn--disabled) {
  background-color: var(--color-gray-700);
  border-color: var(--color-gray-700);
}

.btn--outline {
  background-color: transparent;
  color: var(--color-primary-600);
  border-color: var(--color-primary-600);
}

.btn--outline:hover:not(.btn--disabled) {
  background-color: var(--color-primary-50);
}

.btn--ghost {
  background-color: transparent;
  color: var(--color-gray-700);
  border-color: transparent;
}

.btn--ghost:hover:not(.btn--disabled) {
  background-color: var(--color-gray-100);
}

.btn--danger {
  background-color: var(--color-error);
  color: white;
  border-color: var(--color-error);
}

.btn--danger:hover:not(.btn--disabled) {
  background-color: var(--color-error-dark);
  border-color: var(--color-error-dark);
}

/* Sizes */
.btn--small {
  padding: 0.5rem 0.75rem;
  font-size: 0.875rem;
  line-height: 1.25rem;
}

.btn--medium {
  padding: 0.625rem 1rem;
  font-size: 1rem;
  line-height: 1.5rem;
}

.btn--large {
  padding: 0.75rem 1.5rem;
  font-size: 1.125rem;
  line-height: 1.75rem;
}

/* States */
.btn--disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn--loading {
  color: transparent;
}

.btn__spinner {
  position: absolute;
  width: 1rem;
  height: 1rem;
  border: 2px solid transparent;
  border-top: 2px solid currentColor;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.btn__text--hidden {
  visibility: hidden;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
EOF

    # Card コンポーネント
    cat > "$OUTPUT_DIR/components/Card.jsx" << 'EOF'
import React from 'react';
import PropTypes from 'prop-types';
import './Card.css';

const Card = ({
  children,
  variant = 'default',
  padding = 'medium',
  shadow = 'medium',
  hoverable = false,
  className = '',
  ...props
}) => {
  const baseClass = 'card';
  const variantClass = `card--${variant}`;
  const paddingClass = `card--padding-${padding}`;
  const shadowClass = `card--shadow-${shadow}`;
  const hoverClass = hoverable ? 'card--hoverable' : '';
  
  const classes = [
    baseClass,
    variantClass,
    paddingClass,
    shadowClass,
    hoverClass,
    className
  ].filter(Boolean).join(' ');

  return (
    <div className={classes} {...props}>
      {children}
    </div>
  );
};

Card.propTypes = {
  children: PropTypes.node.isRequired,
  variant: PropTypes.oneOf(['default', 'outlined', 'elevated']),
  padding: PropTypes.oneOf(['none', 'small', 'medium', 'large']),
  shadow: PropTypes.oneOf(['none', 'small', 'medium', 'large']),
  hoverable: PropTypes.bool,
  className: PropTypes.string,
};

export default Card;
EOF
}

# CSS カスタムプロパティ生成
generate_css_custom_properties() {
    local brand="$1"
    
    cat << 'EOF'
:root {
  /* Colors */
  --color-primary-50: #eff6ff;
  --color-primary-100: #dbeafe;
  --color-primary-500: #3b82f6;
  --color-primary-600: #2563eb;
  --color-primary-700: #1d4ed8;
  
  --color-gray-50: #f9fafb;
  --color-gray-100: #f3f4f6;
  --color-gray-500: #6b7280;
  --color-gray-700: #374151;
  --color-gray-900: #111827;
  
  --color-success: #10b981;
  --color-warning: #f59e0b;
  --color-error: #ef4444;
  --color-info: #3b82f6;
  
  /* Typography */
  --font-family-sans: Inter, system-ui, sans-serif;
  --font-size-xs: 0.75rem;
  --font-size-sm: 0.875rem;
  --font-size-base: 1rem;
  --font-size-lg: 1.125rem;
  --font-size-xl: 1.25rem;
  
  /* Spacing */
  --spacing-xs: 0.25rem;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 1.5rem;
  --spacing-xl: 2rem;
  
  /* Border Radius */
  --border-radius-sm: 0.125rem;
  --border-radius-md: 0.375rem;
  --border-radius-lg: 0.5rem;
  
  /* Shadows */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);
}
EOF
}

# スタイルガイド生成
generate_styleguide() {
    log_info "スタイルガイド全体を生成しています..."
    
    load_project_info
    
    # デザインシステム
    generate_design_system "$BRAND_STYLE"
    
    # コンポーネントライブラリ
    generate_components "react"
    
    # ワイヤーフレーム
    generate_wireframes "$PROJECT_TYPE"
    
    # スタイルガイドHTML
    generate_styleguide_html
    
    log_success "スタイルガイド生成完了"
}

# スタイルガイドHTML生成
generate_styleguide_html() {
    cat > "$OUTPUT_DIR/styleguide.html" << 'EOF'
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>スタイルガイド</title>
    <style>
        :root {
            --color-primary: #3b82f6;
            --color-gray-100: #f3f4f6;
            --color-gray-700: #374151;
            --color-gray-900: #111827;
            --spacing-md: 1rem;
            --spacing-lg: 1.5rem;
            --font-family: Inter, system-ui, sans-serif;
        }
        
        body {
            font-family: var(--font-family);
            color: var(--color-gray-900);
            margin: 0;
            padding: var(--spacing-lg);
            background-color: #fff;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .section {
            margin-bottom: 3rem;
            padding: 2rem;
            border: 1px solid var(--color-gray-100);
            border-radius: 0.5rem;
        }
        
        .color-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 1rem;
            margin-top: 1rem;
        }
        
        .color-swatch {
            text-align: center;
            padding: 1rem;
            border-radius: 0.375rem;
            color: white;
            font-weight: 500;
        }
        
        .typography-example {
            margin: 1rem 0;
            padding: 1rem;
            background-color: var(--color-gray-100);
            border-radius: 0.375rem;
        }
        
        .component-example {
            padding: 2rem;
            border: 1px solid var(--color-gray-100);
            border-radius: 0.375rem;
            background-color: #fff;
            margin: 1rem 0;
        }
        
        .btn {
            display: inline-flex;
            align-items: center;
            padding: 0.625rem 1rem;
            border: 1px solid transparent;
            border-radius: 0.375rem;
            font-weight: 500;
            text-decoration: none;
            cursor: pointer;
            margin-right: 0.5rem;
            margin-bottom: 0.5rem;
        }
        
        .btn--primary {
            background-color: var(--color-primary);
            color: white;
        }
        
        .btn--secondary {
            background-color: var(--color-gray-700);
            color: white;
        }
        
        .btn--outline {
            background-color: transparent;
            color: var(--color-primary);
            border-color: var(--color-primary);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>スタイルガイド</h1>
        
        <div class="section">
            <h2>カラーパレット</h2>
            <div class="color-grid">
                <div class="color-swatch" style="background-color: #3b82f6;">
                    Primary<br>#3b82f6
                </div>
                <div class="color-swatch" style="background-color: #6b7280;">
                    Gray<br>#6b7280
                </div>
                <div class="color-swatch" style="background-color: #10b981;">
                    Success<br>#10b981
                </div>
                <div class="color-swatch" style="background-color: #ef4444;">
                    Error<br>#ef4444
                </div>
            </div>
        </div>
        
        <div class="section">
            <h2>タイポグラフィ</h2>
            <div class="typography-example">
                <h1>見出し1 - 32px</h1>
                <h2>見出し2 - 24px</h2>
                <h3>見出し3 - 20px</h3>
                <p>本文テキスト - 16px. この文章は本文のサンプルです。読みやすさを重視したフォントサイズと行間を設定しています。</p>
                <small>小さなテキスト - 14px</small>
            </div>
        </div>
        
        <div class="section">
            <h2>ボタン</h2>
            <div class="component-example">
                <button class="btn btn--primary">Primary Button</button>
                <button class="btn btn--secondary">Secondary Button</button>
                <button class="btn btn--outline">Outline Button</button>
            </div>
        </div>
        
        <div class="section">
            <h2>スペーシング</h2>
            <div class="component-example">
                <div style="padding: 0.25rem; background: #f3f4f6; margin-bottom: 0.5rem;">XS - 4px</div>
                <div style="padding: 0.5rem; background: #f3f4f6; margin-bottom: 0.5rem;">SM - 8px</div>
                <div style="padding: 1rem; background: #f3f4f6; margin-bottom: 0.5rem;">MD - 16px</div>
                <div style="padding: 1.5rem; background: #f3f4f6; margin-bottom: 0.5rem;">LG - 24px</div>
                <div style="padding: 2rem; background: #f3f4f6;">XL - 32px</div>
            </div>
        </div>
    </div>
</body>
</html>
EOF
}

# メイン処理
main() {
    echo "🎨 $AGENT_NAME v$AGENT_VERSION"
    echo "==============================="
    
    # 初期化
    init_uiux
    
    # 引数の処理
    case "$1" in
        --design-system)
            shift
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --brand)
                        generate_design_system "$2"
                        shift 2
                        ;;
                    *)
                        generate_design_system
                        shift
                        ;;
                esac
            done
            ;;
        --wireframes)
            shift
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --type)
                        generate_wireframes "$2"
                        shift 2
                        ;;
                    *)
                        generate_wireframes
                        shift
                        ;;
                esac
            done
            ;;
        --components)
            shift
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --framework)
                        generate_components "$2"
                        shift 2
                        ;;
                    *)
                        generate_components
                        shift
                        ;;
                esac
            done
            ;;
        --styleguide)
            generate_styleguide
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
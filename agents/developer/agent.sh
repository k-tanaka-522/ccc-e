#!/bin/bash
# Developer Agent - 実装支援・コード生成エージェント

# 設定
AGENT_NAME="Developer Agent"
AGENT_VERSION="1.0.0"
REQUIREMENTS_DIR="../requirements"
ARCHITECTURE_DIR="../architecture"
OUTPUT_DIR="../src"
TEMPLATES_DIR="templates/code"

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
💻 Developer Agent v${AGENT_VERSION}
===================================

使用方法:
  $0 [オプション]

オプション:
  --init         プロジェクト初期化（ディレクトリ構造、設定ファイル）
  --generate     コード生成（フレームワーク別）
  --api          REST API生成
  --frontend     フロントエンド生成
  --database     データベース関連コード生成
  --docker       Docker設定生成
  --cicd         CI/CD設定生成
  --tests        テストコード生成
  --docs         API仕様書生成
  --validate     コード品質チェック
  --help         このヘルプを表示

例:
  $0 --init --stack react-node
  $0 --generate --type api
  $0 --frontend --framework react
  $0 --docker
  $0 --cicd --platform github

EOF
}

# 初期化
init_developer() {
    log_info "開発環境を初期化しています..."
    
    # ディレクトリ作成
    mkdir -p "$OUTPUT_DIR" logs tmp
    mkdir -p "$OUTPUT_DIR"/{api,frontend,database,docker,docs,tests}
    
    log_success "開発環境の初期化完了"
}

# 要件・設計の読み込み
load_project_info() {
    log_info "プロジェクト情報を読み込んでいます..."
    
    # 要件定義の読み込み
    if [ ! -f "$REQUIREMENTS_DIR/requirements.md" ]; then
        log_warn "要件定義書が見つかりません"
        PROJECT_TYPE="generic"
        FRAMEWORK="express"
        DATABASE="postgresql"
    else
        # 要件から技術スタック推定
        if grep -qi "EC\|ecommerce\|ショッピング" "$REQUIREMENTS_DIR/requirements.md"; then
            PROJECT_TYPE="ecommerce"
            FRAMEWORK="express"
            DATABASE="postgresql"
        elif grep -qi "API\|SaaS" "$REQUIREMENTS_DIR/requirements.md"; then
            PROJECT_TYPE="api"
            FRAMEWORK="express"
            DATABASE="postgresql"
        elif grep -qi "メディア\|CMS" "$REQUIREMENTS_DIR/requirements.md"; then
            PROJECT_TYPE="cms"
            FRAMEWORK="nextjs"
            DATABASE="postgresql"
        else
            PROJECT_TYPE="webapp"
            FRAMEWORK="express"
            DATABASE="postgresql"
        fi
    fi
    
    # アーキテクチャ情報の読み込み
    if [ -f "$ARCHITECTURE_DIR/design.md" ]; then
        if grep -qi "serverless\|lambda" "$ARCHITECTURE_DIR/design.md"; then
            DEPLOYMENT="serverless"
            FRAMEWORK="lambda"
        elif grep -qi "container\|ecs\|docker" "$ARCHITECTURE_DIR/design.md"; then
            DEPLOYMENT="container"
        else
            DEPLOYMENT="traditional"
        fi
    else
        DEPLOYMENT="traditional"
    fi
    
    log_success "プロジェクト情報読み込み完了"
    log_info "プロジェクト種別: $PROJECT_TYPE, フレームワーク: $FRAMEWORK, DB: $DATABASE, デプロイ: $DEPLOYMENT"
}

# プロジェクト初期化
init_project() {
    local stack="$1"
    stack=${stack:-"react-node"}
    
    log_info "プロジェクト構造を初期化しています: $stack"
    
    load_project_info
    
    case "$stack" in
        "react-node")
            init_react_node_project
            ;;
        "nextjs")
            init_nextjs_project
            ;;
        "serverless")
            init_serverless_project
            ;;
        "django")
            init_django_project
            ;;
        *)
            log_warn "不明なスタック: $stack, デフォルト(react-node)を使用"
            init_react_node_project
            ;;
    esac
    
    # 共通ファイル生成
    generate_common_files
    
    log_success "プロジェクト初期化完了"
}

# React + Node.js プロジェクト初期化
init_react_node_project() {
    log_info "React + Node.js プロジェクト構造を作成中..."
    
    # ディレクトリ構造
    mkdir -p "$OUTPUT_DIR"/{frontend,backend,shared,docs}
    mkdir -p "$OUTPUT_DIR/frontend"/{src,public,components,pages,hooks,utils,styles}
    mkdir -p "$OUTPUT_DIR/backend"/{src,controllers,models,routes,middleware,config,utils}
    mkdir -p "$OUTPUT_DIR/shared"/{types,constants,utils}
    
    # package.json (Backend)
    cat > "$OUTPUT_DIR/backend/package.json" << 'EOF'
{
  "name": "backend-api",
  "version": "1.0.0",
  "description": "Backend API server",
  "main": "src/app.js",
  "scripts": {
    "start": "node src/app.js",
    "dev": "nodemon src/app.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "lint": "eslint src/",
    "lint:fix": "eslint src/ --fix"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "morgan": "^1.10.0",
    "dotenv": "^16.3.1",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.2",
    "express-validator": "^7.0.1",
    "express-rate-limit": "^6.8.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.1",
    "jest": "^29.6.2",
    "supertest": "^6.3.3",
    "eslint": "^8.45.0"
  }
}
EOF

    # package.json (Frontend)
    cat > "$OUTPUT_DIR/frontend/package.json" << 'EOF'
{
  "name": "frontend-app",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.14.2",
    "axios": "^1.4.0",
    "react-query": "^3.39.3",
    "@emotion/react": "^11.11.1",
    "@emotion/styled": "^11.11.0",
    "@mui/material": "^5.14.1",
    "@mui/icons-material": "^5.14.1"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject",
    "lint": "eslint src/",
    "lint:fix": "eslint src/ --fix"
  },
  "devDependencies": {
    "react-scripts": "5.0.1",
    "@testing-library/jest-dom": "^5.16.5",
    "@testing-library/react": "^13.4.0",
    "@testing-library/user-event": "^13.5.0"
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
EOF
}

# Next.js プロジェクト初期化
init_nextjs_project() {
    log_info "Next.js プロジェクト構造を作成中..."
    
    mkdir -p "$OUTPUT_DIR"/{pages,components,styles,lib,hooks,utils,types}
    mkdir -p "$OUTPUT_DIR/pages"/{api,auth}
    
    cat > "$OUTPUT_DIR/package.json" << 'EOF'
{
  "name": "nextjs-app",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "test": "jest",
    "test:watch": "jest --watch"
  },
  "dependencies": {
    "next": "13.4.0",
    "react": "18.2.0",
    "react-dom": "18.2.0",
    "@next/font": "13.4.0",
    "swr": "^2.2.0"
  },
  "devDependencies": {
    "@types/node": "20.4.0",
    "@types/react": "18.2.0",
    "@types/react-dom": "18.2.0",
    "typescript": "5.1.0",
    "eslint": "8.44.0",
    "eslint-config-next": "13.4.0",
    "jest": "^29.6.0",
    "@testing-library/react": "^13.4.0"
  }
}
EOF
}

# Serverless プロジェクト初期化
init_serverless_project() {
    log_info "Serverless プロジェクト構造を作成中..."
    
    mkdir -p "$OUTPUT_DIR"/{functions,layers,resources,events}
    
    cat > "$OUTPUT_DIR/serverless.yml" << 'EOF'
service: serverless-app

provider:
  name: aws
  runtime: nodejs18.x
  region: us-east-1
  stage: ${opt:stage, 'dev'}
  environment:
    STAGE: ${self:provider.stage}
    REGION: ${self:provider.region}

functions:
  api:
    handler: functions/api.handler
    events:
      - http:
          path: /{proxy+}
          method: ANY
          cors: true

  authorizer:
    handler: functions/authorizer.handler

plugins:
  - serverless-offline
  - serverless-webpack

custom:
  webpack:
    webpackConfig: ./webpack.config.js
    includeModules: true
EOF

    cat > "$OUTPUT_DIR/package.json" << 'EOF'
{
  "name": "serverless-app",
  "version": "1.0.0",
  "description": "Serverless application",
  "scripts": {
    "dev": "serverless offline start",
    "deploy": "serverless deploy",
    "test": "jest",
    "lint": "eslint functions/"
  },
  "dependencies": {
    "aws-lambda": "^1.0.7",
    "aws-sdk": "^2.1421.0"
  },
  "devDependencies": {
    "serverless": "^3.33.0",
    "serverless-offline": "^12.0.4",
    "serverless-webpack": "^5.13.0",
    "webpack": "^5.88.0",
    "babel-loader": "^9.1.0",
    "jest": "^29.6.0"
  }
}
EOF
}

# 共通ファイル生成
generate_common_files() {
    # .gitignore
    cat > "$OUTPUT_DIR/.gitignore" << 'EOF'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Build
build/
dist/
.next/
out/

# Logs
logs
*.log

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# AWS
.serverless/
.aws-sam/
EOF

    # README.md
    cat > "$OUTPUT_DIR/README.md" << EOF
# $PROJECT_TYPE Application

## 概要
Generated by Enterprise AI Agent Toolkit

## 技術スタック
- **フレームワーク**: $FRAMEWORK
- **データベース**: $DATABASE  
- **デプロイ**: $DEPLOYMENT

## セットアップ

\`\`\`bash
# 依存関係のインストール
npm install

# 開発サーバー起動
npm run dev
\`\`\`

## ディレクトリ構造
$(generate_directory_structure)

## API仕様
- 詳細は docs/api.md を参照

## テスト
\`\`\`bash
npm test
\`\`\`

## デプロイ
\`\`\`bash
npm run deploy
\`\`\`
EOF

    # 環境変数テンプレート
    cat > "$OUTPUT_DIR/.env.example" << 'EOF'
# Server
PORT=3000
NODE_ENV=development

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=7d

# External APIs
API_KEY=your-api-key

# AWS (if using)
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
EOF
}

# ディレクトリ構造の生成
generate_directory_structure() {
    case "$FRAMEWORK" in
        "express")
            cat << 'EOF'
```
src/
├── backend/
│   ├── src/
│   │   ├── app.js          # メインアプリケーション
│   │   ├── controllers/    # コントローラー
│   │   ├── models/         # データモデル
│   │   ├── routes/         # ルーティング
│   │   ├── middleware/     # ミドルウェア
│   │   └── config/         # 設定
│   └── package.json
├── frontend/
│   ├── src/
│   │   ├── components/     # React コンポーネント
│   │   ├── pages/          # ページコンポーネント
│   │   ├── hooks/          # カスタムフック
│   │   └── utils/          # ユーティリティ
│   └── package.json
└── shared/
    ├── types/              # TypeScript型定義
    └── constants/          # 共通定数
```
EOF
            ;;
        "nextjs")
            cat << 'EOF'
```
src/
├── pages/                  # Next.js ページ
│   └── api/               # API ルート
├── components/            # React コンポーネント
├── styles/               # スタイル
├── lib/                  # ライブラリ
├── hooks/                # カスタムフック
├── utils/                # ユーティリティ
└── types/                # TypeScript型定義
```
EOF
            ;;
        "lambda")
            cat << 'EOF'
```
src/
├── functions/            # Lambda 関数
├── layers/              # Lambda レイヤー
├── resources/           # CloudFormation リソース
└── events/              # イベント定義
```
EOF
            ;;
    esac
}

# API生成
generate_api() {
    local type="$1"
    type=${type:-"rest"}
    
    log_info "API を生成しています: $type"
    
    load_project_info
    
    case "$type" in
        "rest")
            generate_rest_api
            ;;
        "graphql")
            generate_graphql_api
            ;;
        "lambda")
            generate_lambda_api
            ;;
        *)
            log_error "不明なAPI種別: $type"
            return 1
            ;;
    esac
    
    log_success "API生成完了"
}

# REST API生成
generate_rest_api() {
    case "$FRAMEWORK" in
        "express")
            generate_express_api
            ;;
        "nextjs")
            generate_nextjs_api
            ;;
        *)
            log_error "サポートされていないフレームワーク: $FRAMEWORK"
            return 1
            ;;
    esac
}

# Express API生成
generate_express_api() {
    # メインアプリケーション
    cat > "$OUTPUT_DIR/backend/src/app.js" << 'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

// Routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const apiRoutes = require('./routes/api');

// Middleware
const errorHandler = require('./middleware/errorHandler');
const notFound = require('./middleware/notFound');

const app = express();

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use('/api/', limiter);

// Basic middleware
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0'
  });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api', apiRoutes);

// Error handling
app.use(notFound);
app.use(errorHandler);

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📚 API documentation: http://localhost:${PORT}/api/docs`);
});

module.exports = app;
EOF

    # 認証ルート
    mkdir -p "$OUTPUT_DIR/backend/src/routes"
    cat > "$OUTPUT_DIR/backend/src/routes/auth.js" << 'EOF'
const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');

const router = express.Router();

// Mock user data (replace with database)
const users = [];

// Register
router.post('/register', [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 6 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { email, password, name } = req.body;

    // Check if user exists
    const existingUser = users.find(u => u.email === email);
    if (existingUser) {
      return res.status(400).json({ message: 'User already exists' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    // Create user
    const user = {
      id: users.length + 1,
      email,
      name,
      password: hashedPassword,
      createdAt: new Date()
    };
    users.push(user);

    // Generate JWT
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET || 'fallback-secret',
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    res.status(201).json({
      message: 'User created successfully',
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name
      }
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Login
router.post('/login', [
  body('email').isEmail().normalizeEmail(),
  body('password').exists()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { email, password } = req.body;

    // Find user
    const user = users.find(u => u.email === email);
    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Check password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Generate JWT
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET || 'fallback-secret',
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    res.json({
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name
      }
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;
EOF

    # ミドルウェア
    mkdir -p "$OUTPUT_DIR/backend/src/middleware"
    cat > "$OUTPUT_DIR/backend/src/middleware/errorHandler.js" << 'EOF'
const errorHandler = (err, req, res, next) => {
  console.error(err.stack);

  if (err.name === 'ValidationError') {
    return res.status(400).json({
      message: 'Validation Error',
      errors: Object.values(err.errors).map(e => e.message)
    });
  }

  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({ message: 'Invalid token' });
  }

  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({ message: 'Token expired' });
  }

  res.status(500).json({
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
};

module.exports = errorHandler;
EOF

    cat > "$OUTPUT_DIR/backend/src/middleware/notFound.js" << 'EOF'
const notFound = (req, res, next) => {
  res.status(404).json({
    message: `Route ${req.originalUrl} not found`
  });
};

module.exports = notFound;
EOF

    # 認証ミドルウェア
    cat > "$OUTPUT_DIR/backend/src/middleware/auth.js" << 'EOF'
const jwt = require('jsonwebtoken');

const auth = (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ message: 'No token provided' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback-secret');
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ message: 'Invalid token' });
  }
};

module.exports = auth;
EOF
}

# フロントエンド生成
generate_frontend() {
    local framework="$1"
    framework=${framework:-"react"}
    
    log_info "フロントエンドを生成しています: $framework"
    
    case "$framework" in
        "react")
            generate_react_frontend
            ;;
        "nextjs")
            generate_nextjs_frontend
            ;;
        "vue")
            generate_vue_frontend
            ;;
        *)
            log_error "不明なフロントエンドフレームワーク: $framework"
            return 1
            ;;
    esac
    
    log_success "フロントエンド生成完了"
}

# React フロントエンド生成
generate_react_frontend() {
    # メインApp.js
    cat > "$OUTPUT_DIR/frontend/src/App.js" << 'EOF'
import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from 'react-query';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';

// Components
import Header from './components/Header';
import Footer from './components/Footer';

// Pages
import HomePage from './pages/HomePage';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import DashboardPage from './pages/DashboardPage';

// Context
import { AuthProvider } from './contexts/AuthContext';

// Styles
import './App.css';

const queryClient = new QueryClient();

const theme = createTheme({
  palette: {
    primary: {
      main: '#1976d2',
    },
    secondary: {
      main: '#dc004e',
    },
  },
});

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <AuthProvider>
          <Router>
            <div className="App">
              <Header />
              <main className="main-content">
                <Routes>
                  <Route path="/" element={<HomePage />} />
                  <Route path="/login" element={<LoginPage />} />
                  <Route path="/register" element={<RegisterPage />} />
                  <Route path="/dashboard" element={<DashboardPage />} />
                </Routes>
              </main>
              <Footer />
            </div>
          </Router>
        </AuthProvider>
      </ThemeProvider>
    </QueryClientProvider>
  );
}

export default App;
EOF

    # 認証コンテキスト
    mkdir -p "$OUTPUT_DIR/frontend/src/contexts"
    cat > "$OUTPUT_DIR/frontend/src/contexts/AuthContext.js" << 'EOF'
import React, { createContext, useContext, useState, useEffect } from 'react';
import { authService } from '../services/authService';

const AuthContext = createContext();

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      // Verify token and get user info
      authService.verifyToken(token)
        .then((userData) => {
          setUser(userData);
        })
        .catch(() => {
          localStorage.removeItem('token');
        })
        .finally(() => {
          setLoading(false);
        });
    } else {
      setLoading(false);
    }
  }, []);

  const login = async (email, password) => {
    const { token, user } = await authService.login(email, password);
    localStorage.setItem('token', token);
    setUser(user);
    return user;
  };

  const register = async (email, password, name) => {
    const { token, user } = await authService.register(email, password, name);
    localStorage.setItem('token', token);
    setUser(user);
    return user;
  };

  const logout = () => {
    localStorage.removeItem('token');
    setUser(null);
  };

  const value = {
    user,
    login,
    register,
    logout,
    loading
  };

  return (
    <AuthContext.Provider value={value}>
      {!loading && children}
    </AuthContext.Provider>
  );
};
EOF

    # APIサービス
    mkdir -p "$OUTPUT_DIR/frontend/src/services"
    cat > "$OUTPUT_DIR/frontend/src/services/authService.js" << 'EOF'
import axios from 'axios';

const API_BASE = process.env.REACT_APP_API_URL || 'http://localhost:3001/api';

const api = axios.create({
  baseURL: API_BASE,
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle auth errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export const authService = {
  async login(email, password) {
    const response = await api.post('/auth/login', { email, password });
    return response.data;
  },

  async register(email, password, name) {
    const response = await api.post('/auth/register', { email, password, name });
    return response.data;
  },

  async verifyToken(token) {
    const response = await api.get('/auth/verify', {
      headers: { Authorization: `Bearer ${token}` }
    });
    return response.data.user;
  },
};

export default api;
EOF
}

# Docker設定生成
generate_docker() {
    log_info "Docker設定を生成しています..."
    
    load_project_info
    
    case "$DEPLOYMENT" in
        "container")
            generate_docker_compose
            ;;
        "serverless")
            log_info "サーバーレス構成にはDockerは不要です"
            return 0
            ;;
        *)
            generate_docker_compose
            ;;
    esac
    
    log_success "Docker設定生成完了"
}

# Docker Compose生成
generate_docker_compose() {
    # Dockerfile (Backend)
    cat > "$OUTPUT_DIR/Dockerfile" << 'EOF'
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci --only=production

# Copy source code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# Change ownership
RUN chown -R nextjs:nodejs /app
USER nextjs

EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["npm", "start"]
EOF

    # docker-compose.yml
    cat > "$OUTPUT_DIR/docker-compose.yml" << 'EOF'
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://postgres:password@db:5432/app
    depends_on:
      - db
      - redis
    volumes:
      - app_logs:/app/logs
    restart: unless-stopped

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=app
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./docker/postgres/init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./docker/nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./docker/nginx/ssl:/etc/nginx/ssl
    depends_on:
      - app
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
  app_logs:
EOF

    # Nginx設定
    mkdir -p "$OUTPUT_DIR/docker/nginx"
    cat > "$OUTPUT_DIR/docker/nginx/nginx.conf" << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream app {
        server app:3000;
    }

    server {
        listen 80;
        server_name localhost;

        # Redirect HTTP to HTTPS
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl;
        server_name localhost;

        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;

        location / {
            proxy_pass http://app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /health {
            access_log off;
            proxy_pass http://app;
        }
    }
}
EOF
}

# CI/CD設定生成
generate_cicd() {
    local platform="$1"
    platform=${platform:-"github"}
    
    log_info "CI/CD設定を生成しています: $platform"
    
    case "$platform" in
        "github")
            generate_github_actions
            ;;
        "gitlab")
            generate_gitlab_ci
            ;;
        "aws")
            generate_aws_codepipeline
            ;;
        *)
            log_error "不明なCI/CDプラットフォーム: $platform"
            return 1
            ;;
    esac
    
    log_success "CI/CD設定生成完了"
}

# GitHub Actions生成
generate_github_actions() {
    mkdir -p "$OUTPUT_DIR/.github/workflows"
    
    cat > "$OUTPUT_DIR/.github/workflows/ci.yml" << 'EOF'
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  NODE_VERSION: '18'

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
    - uses: actions/checkout@v3

    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'

    - name: Install dependencies
      run: npm ci

    - name: Run linting
      run: npm run lint

    - name: Run tests
      run: npm test
      env:
        DATABASE_URL: postgres://postgres:postgres@localhost:5432/test

    - name: Build application
      run: npm run build

  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Run security audit
      run: npm audit --audit-level=high

    - name: Run Snyk security scan
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

  deploy:
    needs: [test, security]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    - name: Deploy to AWS
      run: |
        # Add your deployment script here
        echo "Deploying to AWS..."
        # Example: aws s3 sync build/ s3://your-bucket/
EOF
}

# テストコード生成
generate_tests() {
    log_info "テストコードを生成しています..."
    
    load_project_info
    
    case "$FRAMEWORK" in
        "express")
            generate_express_tests
            ;;
        "nextjs")
            generate_nextjs_tests
            ;;
        "lambda")
            generate_lambda_tests
            ;;
    esac
    
    log_success "テストコード生成完了"
}

# Express テスト生成
generate_express_tests() {
    mkdir -p "$OUTPUT_DIR/backend/tests"
    
    # テスト設定
    cat > "$OUTPUT_DIR/backend/jest.config.js" << 'EOF'
module.exports = {
  testEnvironment: 'node',
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/app.js',
    '!**/node_modules/**'
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  testMatch: [
    '**/tests/**/*.test.js'
  ],
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js']
};
EOF

    # テストセットアップ
    cat > "$OUTPUT_DIR/backend/tests/setup.js" << 'EOF'
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-secret';
process.env.DATABASE_URL = 'postgresql://postgres:postgres@localhost:5432/test';
EOF

    # 認証テスト
    cat > "$OUTPUT_DIR/backend/tests/auth.test.js" << 'EOF'
const request = require('supertest');
const app = require('../src/app');

describe('Authentication', () => {
  describe('POST /api/auth/register', () => {
    it('should register a new user', async () => {
      const userData = {
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User'
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(userData)
        .expect(201);

      expect(response.body).toHaveProperty('token');
      expect(response.body.user).toHaveProperty('email', userData.email);
      expect(response.body.user).not.toHaveProperty('password');
    });

    it('should not register user with invalid email', async () => {
      const userData = {
        email: 'invalid-email',
        password: 'password123',
        name: 'Test User'
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(userData)
        .expect(400);

      expect(response.body).toHaveProperty('errors');
    });
  });

  describe('POST /api/auth/login', () => {
    it('should login with valid credentials', async () => {
      // First register a user
      await request(app)
        .post('/api/auth/register')
        .send({
          email: 'login@example.com',
          password: 'password123',
          name: 'Login User'
        });

      // Then login
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'login@example.com',
          password: 'password123'
        })
        .expect(200);

      expect(response.body).toHaveProperty('token');
      expect(response.body.user).toHaveProperty('email', 'login@example.com');
    });

    it('should not login with invalid credentials', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'nonexistent@example.com',
          password: 'wrongpassword'
        })
        .expect(401);

      expect(response.body).toHaveProperty('message', 'Invalid credentials');
    });
  });
});
EOF
}

# メイン処理
main() {
    echo "💻 $AGENT_NAME v$AGENT_VERSION"
    echo "================================"
    
    # 初期化
    init_developer
    
    # 引数の処理
    case "$1" in
        --init)
            init_project "$2"
            ;;
        --generate)
            shift
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --type)
                        generate_api "$2"
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done
            ;;
        --api)
            generate_api "$2"
            ;;
        --frontend)
            shift
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --framework)
                        generate_frontend "$2"
                        shift 2
                        ;;
                    *)
                        generate_frontend "react"
                        shift
                        ;;
                esac
            done
            ;;
        --docker)
            generate_docker
            ;;
        --cicd)
            shift
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --platform)
                        generate_cicd "$2"
                        shift 2
                        ;;
                    *)
                        generate_cicd "github"
                        shift
                        ;;
                esac
            done
            ;;
        --tests)
            generate_tests
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
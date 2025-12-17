#!/bin/bash
set -e

echo "🚀 开始安装 WordPress (Docker)..."

# 1️⃣ 检查 Docker
if ! command -v docker >/dev/null 2>&1; then
  echo "❌ Docker 未安装，请先安装 Docker"
  exit 1
fi

# 2️⃣ 检查 Docker Compose
if ! docker compose version >/dev/null 2>&1; then
  echo "❌ Docker Compose 未安装"
  exit 1
fi

# 3️⃣ 询问用户输入 PROJECT_NO / WP_PORT / DB_PORT
read -p "请输入项目编号 PROJECT_NO [默认1]: " PROJECT_NO
PROJECT_NO=${PROJECT_NO:-1}

read -p "请输入 WordPress 访问端口 WP_PORT [默认8080]: " WP_PORT
WP_PORT=${WP_PORT:-8080}

read -p "请输入 MySQL 端口 DB_PORT [默认3306]: " DB_PORT
DB_PORT=${DB_PORT:-3306}

# 4️⃣ 生成 .env
cat > .env <<EOL
PROJECT_NO=$PROJECT_NO
WP_PORT=$WP_PORT
DB_PORT=$DB_PORT
EOL

echo "✅ .env 文件已生成:"
cat .env

# 5️⃣ 创建目录
mkdir -p db-data wordpress

# 6️⃣ 启动 Docker Compose
echo "🐳 启动 Docker Compose..."
docker compose up -d

echo ""
echo "🎉 安装完成！"
echo "🌐 访问 WordPress: http://localhost:$WP_PORT"
echo "📦 项目目录: $(pwd)"

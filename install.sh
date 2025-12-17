#!/bin/bash

set -e

echo "🚀 开始安装 WordPress (Docker)..."

# 1️⃣ 检查 docker
if ! command -v docker >/dev/null 2>&1; then
  echo "❌ 未检测到 Docker，请先安装 Docker"
  exit 1
fi

# 2️⃣ 检查 docker compose
if ! docker compose version >/dev/null 2>&1; then
  echo "❌ 未检测到 docker compose，请升级 Docker Desktop"
  exit 1
fi

# 3️⃣ 创建 .env（如果不存在）
if [ ! -f ".env" ]; then
  echo "📄 未检测到 .env，正在创建..."
  cat > .env <<EOF
PROJECT_NO=1
WP_PORT=8080
DB_PORT=3306
EOF
  echo "✅ .env 已创建"
else
  echo "📄 检测到 .env，跳过创建"
fi

# 4️⃣ 检查 db-data
if [ "$(ls -A db-data 2>/dev/null)" ]; then
  echo "⚠️  db-data 目录非空，将直接使用已有数据库"
else
  echo "📁 db-data 目录为空，MySQL 将进行初始化"
fi

# 5️⃣ 启动服务
echo "🐳 启动 Docker Compose..."
docker compose up -d

# 6️⃣ 输出信息
WP_PORT=$(grep WP_PORT .env | cut -d '=' -f2)

echo ""
echo "🎉 安装完成！"
echo "🌐 访问地址: http://localhost:${WP_PORT}"
echo "📦 项目目录: $(pwd)"

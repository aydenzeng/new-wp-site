#!/bin/bash

# 用法：
# bash bootstrap.sh [本地目录名] [GitHub 仓库地址]
# 示例：
# bash bootstrap.sh site-quote https://github.com/username/site-quote.git

set -e

PROJECT_DIR=${1:-site-quote}
GIT_REPO=${2:-https://github.com/username/site-quote.git}

echo "🚀 开始一键部署项目"

# 1️⃣ 检查 docker
if ! command -v docker >/dev/null 2>&1; then
  echo "❌ Docker 未安装，请先安装 Docker"
  exit 1
fi

# 2️⃣ 检查 docker compose
if ! docker compose version >/dev/null 2>&1; then
  echo "❌ Docker Compose 未安装或版本过低"
  exit 1
fi

# 3️⃣ 克隆项目
if [ -d "$PROJECT_DIR" ]; then
  echo "⚠️  目录 $PROJECT_DIR 已存在，将直接使用已有目录"
else
  echo "📦 克隆 GitHub 项目到 $PROJECT_DIR"
  git clone "$GIT_REPO" "$PROJECT_DIR"
fi

# 4️⃣ 进入项目目录
cd "$PROJECT_DIR"

# 5️⃣ 检查 install.sh 是否存在
if [ ! -f "install.sh" ]; then
  echo "⚠️  install.sh 不存在，创建默认 install.sh"
  cat > install.sh <<'EOF'
#!/bin/bash
set -e

echo "🚀 开始安装 WordPress (Docker)..."

# 检查 docker
if ! command -v docker >/dev/null 2>&1; then
  echo "❌ Docker 未安装"
  exit 1
fi

# 检查 docker compose
if ! docker compose version >/dev/null 2>&1; then
  echo "❌ Docker Compose 未安装"
  exit 1
fi

# 创建 .env
if [ ! -f ".env" ]; then
  cat > .env <<EOL
PROJECT_NO=1
WP_PORT=8080
DB_PORT=3306
EOL
fi

# 创建 db-data 和 wordpress
mkdir -p db-data wordpress

# 启动 docker compose
docker compose up -d

WP_PORT=$(grep WP_PORT .env | cut -d '=' -f2)
echo "🎉 安装完成！访问 http://localhost:${WP_PORT}"
EOF
  chmod +x install.sh
fi

# 6️⃣ 执行 install.sh
echo "🐳 执行 install.sh 一键安装"
chmod +x install.sh
./install.sh

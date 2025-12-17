#!/bin/bash
set -e

DEFAULT_PROJECT="site-quote"
GIT_REPO=${2:-https://github.com/username/site-quote.git}

# 1️⃣ 生成安全的 Docker Compose 项目名
PROJECT_NAME="$DEFAULT_PROJECT"
COUNTER=1
while docker compose -p "$PROJECT_NAME" ps >/dev/null 2>&1; do
    PROJECT_NAME="${DEFAULT_PROJECT}-${COUNTER}"
    COUNTER=$((COUNTER + 1))
done
echo "🚀 Docker Compose 项目名: $PROJECT_NAME"

# 2️⃣ 设置本地目录
PROJECT_DIR="$PROJECT_NAME"
if [ -d "$PROJECT_DIR" ]; then
    echo "⚠️ 目录 $PROJECT_DIR 已存在，将自动生成新目录"
    COUNTER=1
    while [ -d "${PROJECT_DIR}-${COUNTER}" ]; do
        COUNTER=$((COUNTER+1))
    done
    PROJECT_DIR="${PROJECT_DIR}-${COUNTER}"
    echo "📁 使用新目录: $PROJECT_DIR"
fi

# 3️⃣ 克隆项目
git clone "$GIT_REPO" "$PROJECT_DIR"

cd "$PROJECT_DIR"

# 4️⃣ 安装脚本（交互式）
if [ ! -f "install.sh" ]; then
cat > install.sh <<EOF
#!/bin/bash
set -e

echo "🚀 安装 WordPress (Docker)..."

read -p "请输入 WordPress 访问端口 [默认8080]: " WP_PORT
WP_PORT=\${WP_PORT:-8080}
read -p "请输入 MySQL 端口 [默认3306]: " DB_PORT
DB_PORT=\${DB_PORT:-3306}

cat > .env <<EOL
WP_PORT=\$WP_PORT
DB_PORT=\$DB_PORT
EOL

mkdir -p db-data wordpress

# 使用安全的项目名启动 Compose
docker compose -p "$PROJECT_NAME" up -d

echo "🎉 安装完成！访问 http://localhost:\$WP_PORT"
EOF
chmod +x install.sh
fi

# 5️⃣ 执行
./install.sh
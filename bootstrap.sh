#!/bin/bash
set -e

DEFAULT_PROJECT="new-site"
GIT_REPO="https://github.com/aydenzeng/new-wp-site.git"

# 1️⃣ 用户输入项目名
read -p "请输入项目名 [默认 $DEFAULT_PROJECT]: " INPUT_PROJECT
PROJECT_NAME=${INPUT_PROJECT:-$DEFAULT_PROJECT}

# 2️⃣ 检查 Docker Compose 项目名是否被占用
COUNTER=1
ORIGINAL_NAME="$PROJECT_NAME"
# 检查是否已有容器使用该项目名
while [ "$(docker ps -a --filter "name=^${PROJECT_NAME}_" -q | wc -l)" -gt 0 ]; do
    PROJECT_NAME="${ORIGINAL_NAME}-${COUNTER}"
    COUNTER=$((COUNTER + 1))
done

# 3️⃣ 设置本地目录（和项目名保持一致）
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

# 4️⃣ 克隆项目
git clone "$GIT_REPO" "$PROJECT_DIR"

cd "$PROJECT_DIR"

# 5️⃣ 安装脚本（交互式）
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

# 6️⃣ 执行
./install.sh

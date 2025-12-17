#!/bin/bash
set -e

DEFAULT_PROJECT="new-site"
GIT_REPO="https://github.com/aydenzeng/new-wp-site.git"

echo "🚀 一键部署 WordPress (Docker)"

# 1️⃣ 用户输入项目名
read -p "请输入项目名 [默认 $DEFAULT_PROJECT]: " INPUT_PROJECT
PROJECT_NAME=${INPUT_PROJECT:-$DEFAULT_PROJECT}

# 2️⃣ 检查 Docker Compose 项目名是否被占用（容器名冲突）
COUNTER=1
ORIGINAL_NAME="$PROJECT_NAME"
while [ "$(docker ps -a --filter "name=^${PROJECT_NAME}_" -q | wc -l)" -gt 0 ]; do
    PROJECT_NAME="${ORIGINAL_NAME}-${COUNTER}"
    COUNTER=$((COUNTER + 1))
done
echo "🚀 Docker Compose 项目名: $PROJECT_NAME"

# 3️⃣ 设置本地目录（和项目名保持一致）
PROJECT_DIR="$PROJECT_NAME"
if [ -d "$PROJECT_DIR" ]; then
    echo "⚠️ 目录 $PROJECT_DIR 已存在，将自动生成新目录"
    COUNTER=1
    while [ -d "${PROJECT_DIR}-${COUNTER}" ]; do
        COUNTER=$((COUNTER + 1))
    done
    PROJECT_DIR="${PROJECT_DIR}-${COUNTER}"
    echo "📁 使用新目录: $PROJECT_DIR"
fi

# 4️⃣ 克隆项目
git clone "$GIT_REPO" "$PROJECT_DIR"

cd "$PROJECT_DIR"

# 5️⃣ 生成安装脚本（如果不存在）
INSTALL_SCRIPT="install.sh"
if [ ! -f "$INSTALL_SCRIPT" ]; then
cat > "$INSTALL_SCRIPT" <<EOF
#!/bin/bash
set -e

echo "🚀 安装 WordPress (Docker)..."

# 交互式端口输入
read -p "请输入 WordPress 访问端口 [默认8080]: " WP_PORT
WP_PORT=\${WP_PORT:-8080}
read -p "请输入 MySQL 端口 [默认3306]: " DB_PORT
DB_PORT=\${DB_PORT:-3306}

# 写入 .env
cat > .env <<EOL
WP_PORT=\$WP_PORT
DB_PORT=\$DB_PORT
EOL

# 创建数据目录
mkdir -p db-data wordpress

# 启动 Docker Compose
docker compose -p "$PROJECT_NAME" up -d

echo "🎉 安装完成！访问 http://localhost:\$WP_PORT"
EOF

# 立即确保 install.sh 可执行
chmod +x "$INSTALL_SCRIPT"
fi

# 6️⃣ 执行 install.sh，用 bash 保证不会报权限问题
bash "$INSTALL_SCRIPT"

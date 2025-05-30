#!/bin/bash
set -e

USERNAME=$1
GROUPNAME=$2
UID=$3
GID=$4

# 检查组名冲突
if getent group "$GROUPNAME" > /dev/null; then
    EXISTING_GID=$(getent group "$GROUPNAME" | cut -d: -f3)
    if [ "$EXISTING_GID" != "$GID" ]; then
        echo "❌ 组名 $GROUPNAME 已存在，但 GID=$EXISTING_GID ≠ 期望 GID=$GID"
        exit 1
    fi
else
    if getent group "$GID" > /dev/null; then
        echo "❌ GID=$GID 已被其他组占用，无法创建组 $GROUPNAME"
        exit 1
    fi
    groupadd -g "$GID" "$GROUPNAME"
fi

# 检查用户名冲突
if id "$USERNAME" > /dev/null 2>&1; then
    EXISTING_UID=$(id -u "$USERNAME")
    if [ "$EXISTING_UID" != "$UID" ]; then
        echo "❌ 用户名 $USERNAME 已存在，但 UID=$EXISTING_UID ≠ 期望 UID=$UID"
        exit 1
    fi
else
    if getent passwd "$UID" > /dev/null; then
        echo "❌ UID=$UID 已被其他用户占用，无法创建用户 $USERNAME"
        exit 1
    fi
    useradd -m -u "$UID" -g "$GID" -s /bin/bash "$USERNAME"
fi

# 初始化 ~/.ssh 目录
USER_HOME=$(eval echo "~$USERNAME")
SSH_DIR="$USER_HOME/.ssh"
mkdir -p "$SSH_DIR"
chown "$USERNAME:$GROUPNAME" "$SSH_DIR"
chmod 700 "$SSH_DIR"

echo "✅ 用户 $USERNAME (UID=$UID) 和组 $GROUPNAME (GID=$GID) 创建完成"
echo "✅ 初始化 $SSH_DIR 完成，权限 700"

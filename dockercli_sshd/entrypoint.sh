#!/bin/bash
set -e

USER_ID=${UID:-1000}
GROUP_ID=${GID:-1000}
USERNAME=${USERNAME:-dockeruser}
GROUPNAME=${GROUPNAME:-$USERNAME}
DOCKER_GID=${DOCKER_GID:-999}  # 默认 root 所属组 stat -c '%g' /var/run/docker.sock
SSH_KEY_FILE="/tmp/id_rsa.pub"

# ===== 处理组 =====
EXISTING_GROUP=$(getent group "$GROUP_ID" | cut -d: -f1)
if [ -n "$EXISTING_GROUP" ]; then
    echo "Group with GID $GROUP_ID already exists: $EXISTING_GROUP"
    GROUPNAME=$EXISTING_GROUP
else
    if getent group "$GROUPNAME" >/dev/null; then
        GROUPNAME="${GROUPNAME}_${GROUP_ID}"
    fi
    echo "Creating group $GROUPNAME with GID $GROUP_ID"
    groupadd -g "$GROUP_ID" "$GROUPNAME"
fi

# ===== 处理用户 =====
EXISTING_USER=$(getent passwd "$USER_ID" | cut -d: -f1)
if [ -n "$EXISTING_USER" ]; then
    echo "User with UID $USER_ID already exists: $EXISTING_USER"
    USERNAME=$EXISTING_USER
else
    if id "$USERNAME" >/dev/null 2>&1; then
        USERNAME="${USERNAME}_${USER_ID}"
    fi
    echo "Creating user $USERNAME with UID $USER_ID and GID $GROUP_ID ($GROUPNAME)"
    useradd -m -u "$USER_ID" -g "$GROUP_ID" -s /bin/bash "$USERNAME"
fi

# Docker GID 映射组（可选 docker.sock 权限修复）
if [ -n "$DOCKER_GID" ]; then
    DOCKER_GROUP_NAME=dockerhost
    if ! getent group "$DOCKER_GID" >/dev/null; then
        groupadd -g "$DOCKER_GID" "$DOCKER_GROUP_NAME"
    else
        DOCKER_GROUP_NAME=$(getent group "$DOCKER_GID" | cut -d: -f1)
    fi
    usermod -aG "$DOCKER_GROUP_NAME" "$USERNAME"
fi


# ===== 添加到 sudo 组（如果未在组中） =====
if ! id "$USERNAME" | grep -q '\bsudo\b'; then
    usermod -aG sudo "$USERNAME"
fi

# ===== 设置免密 sudo（若未配置） =====
SUDO_FILE="/etc/sudoers.d/$USERNAME"
LINE="$USERNAME ALL=(ALL) NOPASSWD:ALL"

if [ ! -f "$SUDO_FILE" ] || ! grep -Fxq "$LINE" "$SUDO_FILE"; then
    echo "$LINE" > "$SUDO_FILE"
    chmod 0440 "$SUDO_FILE"
fi

# ===== 切换用户执行 =====
# exec sudo -u "$USERNAME" "$@"

# 设置 SSH 公钥
if [ -f "$SSH_KEY_FILE" ]; then
    SSH_HOME="/home/$USERNAME/.ssh"
    mkdir -p "$SSH_HOME"
    cat "$SSH_KEY_FILE" > "$SSH_HOME/authorized_keys"
    chmod 600 "$SSH_HOME/authorized_keys"
    chmod 700 "$SSH_HOME"
    chown -R "$USERNAME:$GROUPNAME" "$SSH_HOME"
fi

exec "$@"

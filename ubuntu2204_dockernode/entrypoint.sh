#!/bin/bash
set -eo pipefail # 遇到错误立即退出，管道失败也退出

exit 0

# 默认的用户名和组名，如果未通过环境变量提供
DEFAULT_CUSTOM_USER_NAME="github_actions_user"
DEFAULT_CUSTOM_GROUP_NAME="github_actions_group" # 默认组名通常与用户名相同

echo "Running entrypoint script..."

# 检查是否提供了 UID 和 GID 环境变量
if [ -n "$UID" ] && [ -n "$GID" ]; then
    # 确定要创建的用户名（从 ACTION_USER_NAME 环境变量获取，如果没有则使用默认值）
    CURRENT_USER_NAME=${ACTION_USER_NAME:-$DEFAULT_CUSTOM_USER_NAME}
    # 确定要创建的组名（从 ACTION_GROUP_NAME 环境变量获取，如果没有则与用户名相同）
    CURRENT_GROUP_NAME=${ACTION_GROUP_NAME:-$CURRENT_USER_NAME}

    echo "Detected UID=$UID, GID=$GID. Desired user name: '$CURRENT_USER_NAME'."

    # 1. 创建组 (如果不存在)
    # 检查是否有组使用目标 GID
    if ! getent group "$GID" >/dev/null; then
        echo "Creating group '$CURRENT_GROUP_NAME' with GID $GID."
        groupadd -g "$GID" "$CURRENT_GROUP_NAME"
    else
        # 如果 GID 已经被占用，则使用现有组的名称
        EXISTING_GROUP_NAME=$(getent group "$GID" | cut -d: -f1)
        echo "Group with GID $GID already exists: '$EXISTING_GROUP_NAME'. Using existing group name."
        CURRENT_GROUP_NAME="$EXISTING_GROUP_NAME"
    fi

    # 2. 创建用户
    # 假设 Dockerfile 中没有 root 之外的用户。
    # 如果提供的 UID 或用户名已经被占用，则会报错退出。
    if getent passwd "$UID" >/dev/null; then
        echo "Error: UID $UID is already in use by user $(getent passwd "$UID" | cut -d: -f1). Cannot create user '$CURRENT_USER_NAME'."
        exit 1
    elif getent passwd "$CURRENT_USER_NAME" >/dev/null; then
        echo "Error: User name '$CURRENT_USER_NAME' is already in use by UID $(id -u "$CURRENT_USER_NAME"). Cannot create user with this name."
        exit 1
    else
        echo "Creating user '$CURRENT_USER_NAME' with UID $UID and GID $GID."
        useradd -u "$UID" -g "$GID" -m -s /bin/bash "$CURRENT_USER_NAME"
    fi

    # 3. 赋予 sudo 权限
    echo "$CURRENT_USER_NAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$CURRENT_USER_NAME"
    chmod 440 "/etc/sudoers.d/$CURRENT_USER_NAME"
    echo "Granted NOPASSWD sudo privileges to '$CURRENT_USER_NAME'."

    # 4. 如果存在 docker 组，则将用户添加到 docker 组
    if getent group docker >/dev/null; then
        echo "Adding '$CURRENT_USER_NAME' to 'docker' group."
        usermod -aG docker "$CURRENT_USER_NAME"
    else
        echo "'docker' group not found. Skipping adding user to 'docker' group."
    fi

    # 5. 更改 /__w 目录的所有权 (对于 GitHub Actions 工作区至关重要)
    if [ -d "/__w" ]; then
        echo "Changing ownership of /__w to $CURRENT_USER_NAME:$CURRENT_GROUP_NAME."
        chown -R "$CURRENT_USER_NAME":"$CURRENT_GROUP_NAME" /__w
    else
        echo "/__w directory not found. Skipping ownership change."
    fi

    # 6. 以新用户身份执行传入的命令
    echo "Executing command as '$CURRENT_USER_NAME': $@"
    exec su "$CURRENT_USER_NAME" -c "$*"

else
    echo "UID and GID environment variables not provided. Executing command as root: $@"
    # 如果没有提供 UID/GID，则以 root 身份执行传入的命令
    exec "$@"
fi
#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/ssh-tunnel.log"
MAX_LOG_SIZE=$((6 * 1024 * 1024))      # 6MB
TARGET_LOG_SIZE=$((5 * 1024 * 1024))   # 5MB

trim_log_if_needed() {
    if [ -f "$LOG_FILE" ]; then
        local file_size
        file_size=$(stat -c%s "$LOG_FILE")
        if [ "$file_size" -gt "$MAX_LOG_SIZE" ]; then
            echo "[$(date '+%F %T')] 🔄 日志超过阈值，裁剪到 ${TARGET_LOG_SIZE} 字节" | tee -a "$LOG_FILE"
            tail -c "$TARGET_LOG_SIZE" "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
        fi
    fi
}

REMOTE_USER="user"
REMOTE_HOST="remote.example.com"
REMOTE_PORT=22
LOCAL_PORT=8080
REMOTE_FORWARD_PORT=10080
SSH_KEY="${HOME}/.ssh/id_rsa"

echo "🚀 启动 SSH 端口转发..." | tee -a "$LOG_FILE"

while true; do
    trim_log_if_needed

    # ssh 输出同时写文件和stdout，stderr重定向到stdout
    ssh -o ServerAliveInterval=60 \
        -o ServerAliveCountMax=3 \
        -o ExitOnForwardFailure=yes \
        -i "$SSH_KEY" \
        -N -R ${REMOTE_FORWARD_PORT}:localhost:${LOCAL_PORT} \
        -p ${REMOTE_PORT} \
        ${REMOTE_USER}@${REMOTE_HOST} 2>&1 | tee -a "$LOG_FILE"

    echo "[$(date '+%F %T')] ❌ SSH 连接断开，5 秒后重试..." | tee -a "$LOG_FILE"
    sleep 5
done

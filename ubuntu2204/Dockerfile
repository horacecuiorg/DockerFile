FROM ghcr.io/horacecuiorg/dockerfile/ubuntu2204:basesoft

LABEL org.opencontainers.image.source https://github.com/horacecuiorg/dockerfile

ENV DEBIAN_FRONTEND=noninteractive
ARG NODE_VERSION=20.11.1
ARG TARGETARCH  # amd64 and  arm64




# cloudflared
RUN case "$TARGETARCH" in \
      amd64) ARCH="amd64" ;; \
      arm64) ARCH="arm64" ;; \
      *) echo "Unsupported architecture: $TARGETARCH" && exit 1 ;; \
    esac && \
    curl -fsSL -o /usr/local/bin/cloudflared \
      "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${ARCH}" && \
    chmod +x /usr/local/bin/cloudflared && \
    cloudflared --version

# node
#RUN ARCH=$TARGETARCH && \
#    case "$ARCH" in \
#      amd64) ARCH_NAME="x64" ;; \
#      arm64) ARCH_NAME="arm64" ;; \
#      *) echo "Unsupported arch: $ARCH" && exit 1 ;; \
#    esac && \
#    curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH_NAME}.tar.xz \
#    | tar -xJ -C /usr/local --strip-components=1 && \
#    node -v && npm -v




# --- 直接创建 runner 用户 (UID 1001) ---
RUN groupadd -g 1001 runner && \
    useradd -u 1001 -g 1001 -m -s /bin/bash runner && \
    echo "runner:runner" | chpasswd && \
    adduser runner sudo && \
    # 如果 docker 组存在，将 runner 用户加入 docker 组
    if getent group docker >/dev/null; then usermod -aG docker runner; fi

# 允许 runner 用户在使用 sudo 时不需要密码
RUN echo "runner ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/runner && \
    chmod 440 /etc/sudoers.d/runner

# 设置工作目录为用户主目录
WORKDIR /home/runner

# 设置 runner 用户为默认用户
USER runner
# 默认进入 shell
CMD ["/bin/bash"]

# 构建镜像
# docker build -t ubuntu22.04 .
# 构建多平台镜像load
# docker buildx build --platform linux/amd64,linux/arm64 --load -t ubuntu22.04 .
# 构建多平台镜像push
# docker buildx build --platform linux/amd64,linux/arm64 --push -t ubuntu22.04 .
# 运行容器
# docker run -it --rm ubuntu22.04
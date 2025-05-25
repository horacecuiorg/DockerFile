FROM ubuntu:22.04
LABEL org.opencontainers.image.source https://github.com/horacecuiorg/dockerfile

# 安装必要软件
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget gnupg lsb-release \
    git unzip zip tar vim nano htop iproute2 iputils-ping net-tools \
    xz-utils openssh-client \
    sudo bash && \
    build-essential software-properties-common \
    python3 python3-pip python3-venv \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 更新
RUN apt-get update && apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*

# 安装docker -cli 
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# 安装node lts
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm && \
    rm -rf /var/lib/apt/lists/*


# 默认进入 shell
CMD ["/bin/bash"]


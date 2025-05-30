FROM ubuntu:22.04

# 安装 ssh 客户端
RUN apt-get update && apt-get install -y \
    openssh-client \
    bash \
    && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
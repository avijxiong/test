# 使用alpine:latest作为基础镜像
FROM alpine:latest

# 设置时区为上海
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata

# 安装必要的工具
RUN apk add --no-cache dcron

# 定义构建参数
ARG CFNAT_AMD64
ARG CFNAT_ARM64
ARG COLO_AMD64
ARG COLO_ARM64

# 复制二进制文件到镜像中并授予执行权限
COPY ${CFNAT_AMD64} ${CFNAT_ARM64} /usr/local/bin/
COPY ${COLO_AMD64} ${COLO_ARM64} /usr/local/bin/
RUN if [ "$(uname -m)" = "x86_64" ]; then \
        mv /usr/local/bin/${CFNAT_AMD64} /usr/local/bin/cfnat && \
        mv /usr/local/bin/${COLO_AMD64} /usr/local/bin/colo; \
    else \
        mv /usr/local/bin/${CFNAT_ARM64} /usr/local/bin/cfnat && \
        mv /usr/local/bin/${COLO_ARM64} /usr/local/bin/colo; \
    fi && \
    chmod +x /usr/local/bin/cfnat /usr/local/bin/colo


# 创建日志目录
RUN mkdir -p /var/log/cfnat

# 添加定时任务
RUN echo "0 3 * * * /usr/local/bin/run-colo.sh >> /var/log/cfnat/colo.log 2>&1" >> /etc/crontabs/root && \
    echo "10 3 * * * /usr/local/bin/restart-cfnat.sh >> /proc/1/fd/1 2>&1" >> /etc/crontabs/root

# 创建启动脚本
RUN echo '#!/bin/sh' > /usr/local/bin/start.sh && \
    echo 'cd /usr/local/bin' >> /usr/local/bin/start.sh && \
    echo 'crond' >> /usr/local/bin/start.sh && \
    echo 'exec ./cfnat' >> /usr/local/bin/start.sh && \
    chmod +x /usr/local/bin/start.sh

# 创建colo运行脚本
RUN echo '#!/bin/sh' > /usr/local/bin/run-colo.sh && \
    echo 'cd /usr/local/bin' >> /usr/local/bin/run-colo.sh && \
    echo 'echo "$(date): Starting colo"' >> /usr/local/bin/run-colo.sh && \
    echo './colo' >> /usr/local/bin/run-colo.sh && \
    echo 'echo "$(date): colo finished with exit code $?"' >> /usr/local/bin/run-colo.sh && \
    chmod +x /usr/local/bin/run-colo.sh

# 创建cfnat重启脚本
RUN echo '#!/bin/sh' > /usr/local/bin/restart-cfnat.sh && \
    echo 'cd /usr/local/bin' >> /usr/local/bin/restart-cfnat.sh && \
    echo 'echo "$(date): Restarting cfnat"' >> /usr/local/bin/restart-cfnat.sh && \
    echo 'pkill cfnat' >> /usr/local/bin/restart-cfnat.sh && \
    echo 'sleep 5' >> /usr/local/bin/restart-cfnat.sh && \
    echo 'exec ./cfnat' >> /usr/local/bin/restart-cfnat.sh && \
    chmod +x /usr/local/bin/restart-cfnat.sh

# 设置工作目录
WORKDIR /usr/local/bin

# 设置启动命令
CMD ["./start.sh"]

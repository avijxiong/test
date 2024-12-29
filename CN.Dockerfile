# 第一阶段: 构建tgcrypto
FROM python:3.12-slim AS builder

RUN apt-get update && apt-get install -y gcc && \
    mkdir -p build && \
    pip wheel -w build tgcrypto

# 第二阶段: 最终镜像
FROM python:3.12-slim
COPY --from=builder /build/*.whl /tmp/

RUN pip install /tmp/*.whl && \
    pip install -U "tg-signer[tgcrypto]"

# 设置工作目录
WORKDIR /opt/tg-signer

# 复制并设置入口点脚本
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"] 
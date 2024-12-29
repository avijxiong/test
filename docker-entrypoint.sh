#!/bin/bash

# 检查配置文件是否存在
if [ -f "/opt/tg-signer/tasks.yaml" ]; then
    # 配置文件存在,运行tg-signer
    exec tg-signer run mytasks
else
    # 配置文件不存在,无限sleep等待配置
    exec sleep infinity
fi 
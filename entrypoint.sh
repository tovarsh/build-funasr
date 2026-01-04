#!/bin/bash

# 开启 bash 错误追踪
set -e

echo "--------------------------------------------------"
echo "启动 FunASR CPU 全能服务 (Created by Lumen)"
echo "Base Image: FunASR Runtime SDK 0.4.7"
echo "--------------------------------------------------"

# 读取环境变量，如果不存在则使用默认值 (虽然 Dockerfile 已设，这里做双重保险)
# shell 语法: ${VAR:-default}
IO_THREAD=${IO_THREAD_NUM:-4}
DEC_THREAD=${DECODER_THREAD_NUM:-4}
SRV_PORT=${PORT:-10095}
SSL_CERT=${CERT_FILE:-0}

echo ">>> 配置参数:"
echo "    Port: $SRV_PORT"
echo "    IO Threads: $IO_THREAD"
echo "    Decoder Threads: $DEC_THREAD"
echo "    SSL Cert: $SSL_CERT"
echo "--------------------------------------------------"

# 使用 exec 启动，确保 funasr 进程成为 PID 1，能够接收 docker stop 信号
exec ./funasr-wss-server \
  --model-dir /workspace/models/asr \
  --vad-dir /workspace/models/vad \
  --punc-dir /workspace/models/punc \
  --vad-quant true \
  --punc-quant true \
  --port "${SRV_PORT}" \
  --certfile "${SSL_CERT}" \
  --io-thread-num "${IO_THREAD}" \
  --decoder-thread-num "${DEC_THREAD}"
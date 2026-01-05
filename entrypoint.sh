#!/bin/bash
set -e

echo "--------------------------------------------------"
echo "启动 FunASR CPU 2Pass 服务 (Online Image 0.1.12)"
echo "--------------------------------------------------"

# 读取环境变量
IO_THREAD=${IO_THREAD_NUM:-4}
DEC_THREAD=${DECODER_THREAD_NUM:-4}
SRV_PORT=${PORT:-10095}
SSL_CERT=${CERT_FILE:-0}

# 绝对路径
BIN_PATH="/workspace/FunASR/runtime/websocket/build/bin/funasr-wss-server"

echo ">>> Bin路径: $BIN_PATH"
echo ">>> 正在加载模型..."

exec $BIN_PATH \
  --model-dir /workspace/models/asr_offline \
  --vad-dir /workspace/models/vad \
  --punc-dir /workspace/models/punc \
  --itn-dir /workspace/models/itn \
  --lm-dir /workspace/models/lm \
  --vad-quant true \
  --punc-quant true \
  --port "${SRV_PORT}" \
  --certfile "${SSL_CERT}" \
  --io-thread-num "${IO_THREAD}" \
  --decoder-thread-num "${DEC_THREAD}"
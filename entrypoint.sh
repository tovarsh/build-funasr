#!/bin/bash
set -e

echo "--------------------------------------------------"
echo "启动 FunASR CPU 纯离线版 (Final Offline)"
echo "--------------------------------------------------"

# 读取环境变量
IO_THREAD=${IO_THREAD_NUM:-4}
DEC_THREAD=${DECODER_THREAD_NUM:-4}
SRV_PORT=${PORT:-10095}
SSL_CERT=${CERT_FILE:-0}

# 绝对路径
BIN_PATH="/workspace/FunASR/runtime/websocket/build/bin/funasr-wss-server"

echo ">>> Bin路径: $BIN_PATH"
echo ">>> 正在加载本地模型 (ASR + VAD + PUNC + ITN + LM)..."

# 🔥 显式指定所有路径，堵死联网缺口
exec $BIN_PATH \
  --model-dir /workspace/models/asr \
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
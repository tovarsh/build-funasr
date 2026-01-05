# download.py
import os
from modelscope import snapshot_download

# 1. 确认下载目录
if not os.path.exists('./model'):
    os.makedirs('./model')

print("正在下载最新模型资源 (iic/Newest Models)...")

# 2. 下载 ASR 模型
# 下载离线模型 (用于 2Pass 中的修正 或 纯离线转写)
print("Downloading Offline Model (for 2Pass correction)...")
snapshot_download('iic/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-onnx',
                  local_dir='./model/asr_offline')

# 下载流式模型 (用于实时上屏)
print("Downloading Online Model (for Streaming)...")
snapshot_download('iic/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-online-onnx',
                  local_dir='./model/asr_online')

# 3. 下载 VAD 模型 (语音活动检测)
# 用于切分语音和静音，FSMN 是目前的标配
print("Downloading VAD (FSMN)...")
snapshot_download('iic/speech_fsmn_vad_zh-cn-16k-common-onnx',
                  local_dir='./model/vad')

# 4. 下载 PUNC 模型 (标点恢复)
# 实时加标点
print("Downloading PUNC (CT-Transformer)...")
snapshot_download('iic/punc_ct-transformer_zh-cn-common-vocab272727-onnx',
                  local_dir='./model/punc')

# 4. 下载 ITN 模型 (时间处理)
print("Downloading ITN...")
snapshot_download('thuduj12/fst_itn_zh',
                  local_dir='./model/itn')

print("Downloading LM ...")
snapshot_download('damo/speech_ngram_lm_zh-cn-ai-wesp-fst',
                  local_dir='./model/lm')

print("所有模型下载完成！准备构建 Docker 镜像。")
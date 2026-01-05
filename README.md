# FunASR CPU All-in-One Docker Image

这个项目用于构建一个**开箱即用、全平台支持 (AMD64/ARM64)、纯 CPU 推理**的 FunASR 服务镜像。

该镜像基于 Alibaba FunASR Runtime SDK 0.4.x (Runtime 2.0)，**内置了**最新的语音识别模型资源，部署时无需挂载外部卷。

---

## 分支版本

> Online（流式）采用分块/2Pass 算法，专用于需要即时看到文字的实时交互场景（如语音输入法、直播字幕）；
> Offline（离线）采用全局 SAN-M 并行算法，专用于追求极致吞吐量和精度的文件转写场景（如会议录音归档）。

- online: 实时识别 + 离线修正 双模式 (用户侧实时用)
- offline: 纯离线 (后端ASR需求用)

## 核心特性

* **纯 CPU 推理**: 针对 CPU 优化，无需 GPU。
* **内置模型**: 镜像内包含 Paraformer (ASR), FSMN (VAD), CT-Transformer (Punc)。
* **双模式支持**: 同时支持**实时流式 (Real-time)** 和 **离线文件 (Offline/2Pass)** 转写。
* **0 配置启动**: 启动命令无需指定复杂的模型路径参数。
* **全平台**: 支持 Linux/AMD64 和 Linux/ARM64 (如 Mac M芯片, 树莓派)。

---

## 目录结构

在构建前，请确保目录结构如下：

```text
.
├── Dockerfile          # 构建描述文件
├── README.md           # 本文档
├── download.py         # 模型下载脚本 (Python)
├── entrypoint.sh       # 容器启动入口脚本
└── model/              # [构建时生成] 存放下载的模型文件
└── demo/              # [测试] 官方测试运行情况示例 

```

---

## 构建步骤 (Build Steps)

### 1. 准备构建环境

确保宿主机安装了 Python3 和 `modelscope` 库：

```bash
pip install modelscope
```

### 2. 下载最新模型

执行 Python 脚本，将模型下载到本地 `model/` 目录。这是为了利用 Docker 缓存层，避免每次构建都重新下载大文件。

**执行下载：**

```bash
python3 download.py
```

### 3. 执行构建与推送

使用 `docker buildx` 构建多架构镜像并推送到腾讯云仓库：

```bash
# 替换为你的实际镜像仓库地址
export IMAGE_NAME="my/asr:cpu"

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t $IMAGE_NAME \
  --push \
  .

```

---

## 部署运行

构建完成后，在任何服务器上运行以下命令即可，无需挂载卷，无需配置：

```bash
docker run -d \
  --name funasr-cpu \
  -p 10095:10095 \
  --restart always \
  ccr.ccs.tencentyun.com/lumen/asr:cpu
```

---

## 客户端调用 (Usage)

由于底层升级到了 Runtime 2.0 协议，请使用支持新协议的客户端。

### Python 客户端示例

安装依赖：

```bash
pip install funasr-wss-client

```

测试代码： 参考 `demo\html\index.html`

---

## 版本记录

* **Base Image**: `funasr-runtime-sdk-cpu-0.4.7`
* **ASR Model**: `paraformer-large-online-onnx` (2Pass)
* **VAD Model**: `fsmn-vad-online-onnx`
* **Punc Model**: `ct-transformer-punc-onnx`
* **Maintainer**: `J.K.`
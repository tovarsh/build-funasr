# FunASR CPU Docker Images

本项目用于构建基于 Alibaba FunASR Runtime SDK 的纯 CPU 语音识别服务镜像。项目旨在提供开箱即用、无需 GPU 依赖、支持多架构（AMD64/ARM64）的标准化推理环境。

镜像通过预置模型权重文件，实现了服务的无状态部署，无需在运行时挂载外部存储卷。

## 架构分支说明

本项目提供两种针对不同业务场景优化的镜像分支：

### 1. Online 分支 (流式版)

* **标签**: `:online`
* **基础镜像**: `funasr-runtime-sdk-online-cpu-0.1.12`
* **公益国内镜像**: `ccr.ccs.tencentyun.com/comintern/asr:online`
* **公益国外镜像**: `ghcr.io/tovarsh/funasr:online`
* **核心算法**: 采用分块 (Chunk-based) 与 2Pass (两遍) 联合解码算法。
* **适用场景**: 实时语音输入法、直播实时字幕、语音助手等对延迟敏感的即时交互场景。
* **特性**: 支持实时流式输入，并在句尾进行高精度离线修正。

### 2. Offline 分支 (离线版)

* **标签**: `:offline`
* **基础镜像**: `funasr-runtime-sdk-cpu-0.4.7`
* **公益国内镜像**: `ccr.ccs.tencentyun.com/comintern/asr:offline`
* **公益国外镜像**: `ghcr.io/tovarsh/funasr:offline`
* **核心算法**: 采用全局 SAN-M (Self-Attention Network with Memory) 并行计算算法。
* **适用场景**: 视频人声提取、会议录音归档、客服通话质检、长音频文件转写等对吞吐量要求极高的后端批处理任务。
* **特性**: 不支持流式输入，专注于全量音频文件的高速转写。

### 3. Offline_ai 分支 (离线版)

-[ ] 待优质低成本模型发展技术下放, 提取人声能识别感情、角色等功能

## 技术特性

* **纯 CPU 推理**: 针对 CPU 指令集优化，降低部署成本，无需显卡资源。
* **内置模型资源**: 镜像内集成 Paraformer (ASR)、FSMN (VAD) 及 CT-Transformer (Punc) 模型，实现零依赖启动。
* **跨平台支持**: 构建脚本支持 `linux/amd64` (x86_64) 及 `linux/arm64` (aarch64/Apple Silicon) 架构。
* **标准化协议**: 基于 FunASR Runtime 2.0 协议，兼容官方 WebSocket 客户端。

## 目录结构

构建环境需保持以下目录结构：

```text
.
├── Dockerfile          # 多阶段构建描述文件
├── README.md           # 项目说明文档
├── download.py         # 模型资源下载脚本
├── entrypoint.sh       # 服务启动引导脚本
├── model/              # [构建产物] 存放下载的模型文件
└── demo/               # 客户端调用示例代码

```

## 构建指南

### 1. 环境准备

宿主机需安装 Python 3 环境及 `modelscope` 依赖库，用于获取模型资源。

```bash
pip install modelscope

```

### 2. 获取模型资源

执行预置脚本将模型权重下载至本地 `model/` 目录。此步骤旨在利用 Docker 构建缓存机制，避免重复下载。

```bash
python3 download.py

```

### 3. 构建与推送

使用 `docker buildx` 进行多架构构建。根据需求选择构建特定分支或同时构建。

**构建 Online 分支:**

```bash
# IMAGE_NAME: ccr.ccs.tencentyun.com/lumen/asr:online
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t <IMAGE_NAME>:online \
  -f Dockerfile.online \
  --push .

```

**构建 Offline 分支:**

```bash
# IMAGE_NAME: ccr.ccs.tencentyun.com/lumen/asr:offline
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t <IMAGE_NAME>:offline \
  -f Dockerfile.offline \
  --push .

```

*(注：如使用单一 Dockerfile，请在构建命令中通过 `--build-arg` 或修改 Dockerfile 中的 FROM 指令来切换基础镜像)*

## 部署说明

容器启动时无需额外配置参数，端口映射请根据分支类型进行区分。

### 启动 Online 服务

```bash
docker run -d \
  --name funasr-online \
  -p 10095:10095 \
  --restart always \
  ccr.ccs.tencentyun.com/lumen/asr:online

```

### 启动 Offline 服务

```bash
docker run -d \
  --name funasr-offline \
  -p 10095:10095 \
  --restart always \
  ccr.ccs.tencentyun.com/lumen/asr:offline

```

## 客户端接入

服务基于 Runtime 2.0 协议。

### Python 客户端

安装官方客户端库：

```bash
pip install funasr-wss-client

```

### Web/JS 客户端

请参考本项目提供的示例代码：`demo/html/index.html`。

## 版本规格说明

| 组件 | Online 分支 | Offline 分支 |
| --- | --- | --- |
| **Runtime SDK** | 0.1.12 (Online) | 0.4.7 (Offline) |
| **ASR Model** | paraformer-large-online-onnx | paraformer-large-onnx |
| **VAD Model** | fsmn-vad-online-onnx | fsmn-vad-onnx |
| **Punc Model** | ct-transformer-punc-onnx | ct-transformer-punc-onnx |
| **默认端口** | 10095 | 10095 |

---

**Maintainer**: J.K.

# 使用官方最新的 CPU Runtime SDK
# 包含了 ONNXRuntime, OpenBLAS 等底层依赖
FROM registry.cn-hangzhou.aliyuncs.com/funasr_repo/funasr:funasr-runtime-sdk-online-cpu-0.1.12
MAINTAINER J.Knight<jk@sov.red>
WORKDIR /workspace

# 1. 复制模型资源
COPY model/ /workspace/models/

# 2. 复制启动脚本
COPY entrypoint.sh /workspace/entrypoint.sh
RUN sed -i 's/\r$//' /workspace/entrypoint.sh
RUN chmod +x /workspace/entrypoint.sh

# 3. 设置默认环境变量 (可以在 docker run 或 docker-compose 中覆盖)
# IO_THREAD_NUM: IO线程数
# DECODER_THREAD_NUM: 解码线程数 (最吃CPU的部分)
# PORT: 服务端口
# CERT_FILE: SSL证书路径 (0代表关闭)
ENV IO_THREAD_NUM=4 \
    DECODER_THREAD_NUM=4 \
    PORT=10095 \
    CERT_FILE=0

# 4. 暴露端口
EXPOSE 10095

# 5. 启动
ENTRYPOINT ["/workspace/entrypoint.sh"]
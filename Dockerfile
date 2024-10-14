# 第一阶段：构建 Go 二进制文件
FROM golang:1.23.2 AS builder
WORKDIR /go/src/github.com/YuCN0010/DeepLX
COPY . .

# 初始化 Go 模块（如果还没有 go.mod 文件）
RUN go mod init github.com/YuCN0010/DeepLX || true

# 下载依赖
RUN go mod download

# 编译 Go 代码
RUN CGO_ENABLED=0 go build -o deeplx .

# 第二阶段：构建最终镜像
FROM alpine:latest

# 设置工作目录
WORKDIR /app

# 复制 Go 二进制文件
COPY --from=builder /go/src/github.com/YuCN0010/DeepLX/deeplx /app/deeplx

# 复制 cloudflared 二进制文件
COPY --from=cloudflare/cloudflared:latest /usr/local/bin/cloudflared /usr/local/bin/cloudflared

# 暴露端口
EXPOSE 11888

# 设置数据目录
WORKDIR /data
RUN chmod 777 -R /data

# 启动服务
ENTRYPOINT cloudflared tunnel --no-autoupdate run --token $CF_TOKEN & \
           /app/deeplx

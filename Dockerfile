# 基础镜像说明
FROM openjdk:17-ea-slim
# FROM ubuntu:22.04
# RUN apt-get update && apt-get install -y curl iputils-ping openjdk-17-jdk
# ↑ 这个镜像本身就包含了 Alpine Linux + JDK
# Alpine 是一个超小的 Linux 发行版（只有5MB）

# RUN apt-get update && apt-get install -y curl iputils-ping 
# 创建工作目录
RUN mkdir /app
WORKDIR /app

# 复制jar包
COPY target/eureka-server-peer-0.0.1-SNAPSHOT.jar /app/

# 暴露端口 - 修正：每个容器只暴露自己用的端口
# 但为了灵活性，我们把三个端口都暴露
EXPOSE 8761 8762 8763

# 启动命令
ENTRYPOINT ["java", "-jar", "/app/eureka-server-peer-0.0.1-SNAPSHOT.jar"]

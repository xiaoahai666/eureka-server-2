# 基础镜像
FROM openjdk:17-ea-slim
# FROM ubuntu:22.04
# RUN apt-get update && apt-get install -y curl iputils-ping openjdk-17-jdk

# 创建工作目录
RUN mkdir /app
WORKDIR /app

# 复制jar包
COPY target/eureka-server-peer-0.0.1-SNAPSHOT.jar /app/

# 暴露端口
EXPOSE 8761 8762 8763

# 启动命令
ENTRYPOINT ["java", "-jar", "/app/eureka-server-peer-0.0.1-SNAPSHOT.jar"]

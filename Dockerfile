# 使用国内同步的 OpenJDK 运行环境
FROM swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/library/openjdk:17-jdk-slim
# 指定工作目录
WORKDIR /app
# 将打包好的 jar 文件复制到容器中
COPY target/novasoar-tax.jar app.jar
# 暴露应用端口
EXPOSE 8089
# 启动命令
ENTRYPOINT ["java", "-jar", "app.jar"]
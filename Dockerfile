# 使用官方的 OpenJDK 运行环境
FROM openjdk:17-jdk-slim
# 指定工作目录
WORKDIR /app
# 将打包好的 jar 文件复制到容器中
COPY target/novasoar-tax.jar app.jar
# 暴露应用端口（例如 8080）
EXPOSE 8080
# 启动命令
ENTRYPOINT ["java", "-jar", "app.jar"]
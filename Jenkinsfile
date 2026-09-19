pipeline {
    agent any
    tools {
        maven 'Maven-3.8.novalsoar' // 对应你在 Jenkins Tools 中配置的 Maven 名称
    }
    stages {
        stage('1. 拉取代码') {
            steps {
                // 使用凭证拉取 GitHub 私有仓库代码
                checkout([$class: 'GitSCM',
                    branches: [[name: 'main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/Edgarmongo/novasoar-tax.git',
                        credentialsId: 'github-cred' // 对应你在 Jenkins 里填写的 GitHub 凭证 ID
                    ]]
                ])
            }
        }
        stage('2. Maven 编译打包') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
        stage('3. 构建 Docker 镜像') {
            steps {
                script {
                    sh 'docker build -t 192.168.0.152/novasoar-tax/novasoar-tax:${BUILD_NUMBER} .'
                }
            }
        }
        stage('4. 推送镜像到 Harbor') {
            steps {
                script {
                    // 使用 Jenkins 中配置的 Harbor 凭证（凭证 ID 为 harbor-cred）
                    withCredentials([usernamePassword(credentialsId: 'harbor-cred', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh 'echo $PASS | docker login 192.168.0.152 -u $USER --password-stdin'
                        sh 'docker push 192.168.0.152/novasoar-tax/novasoar-tax:${BUILD_NUMBER}'
                    }
                }
            }
        }
    }
}
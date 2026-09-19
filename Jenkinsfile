pipeline {
    agent any
    tools {
        maven 'Maven-3.8.novalsoar'
    }
    stages {
        stage('1. 拉取代码') {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: 'main']],
                    userRemoteConfigs: [[
                        url: 'git@github.com:Edgarmongo/novasoar-tax.git',
                        credentialsId: 'github-ssh-cred'
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
                    // 【修改点 1】加上 8888 端口
                    sh 'docker build -t 192.168.0.152:8888/novasoar-tax/novasoar-tax:${BUILD_NUMBER} .'
                }
            }
        }
        stage('4. 推送镜像到 Harbor') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'harbor-cred', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        // 【修改点 2】docker login 和 push 都要加上 8888 端口
                        sh 'echo $PASS | docker login 192.168.0.152:8888 -u $USER --password-stdin'
                        sh 'docker push 192.168.0.152:8888/novasoar-tax/novasoar-tax:${BUILD_NUMBER}'
                    }
                }
            }
        }
    }
}
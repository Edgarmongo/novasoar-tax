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
         stage('5. 拉取配置并部署到 Kubernetes') {
            steps {
                script {
                    // 清理旧的配置目录（如果存在）
                    sh 'rm -rf noval-helm'
                    
                    // 使用相同的 SSH 凭证克隆配置仓库
                    // 注意：这里需要确保 Jenkins 节点配置了访问该仓库的权限，或者使用 HTTPS 凭证
                    sh 'git clone git@github.com:Edgarmongo/noval-helm.git'
                    
                    // 替换 yaml 文件中的镜像版本号
                    sh "sed -i 's#__IMAGE_TAG__#${BUILD_NUMBER}#g' noval-helm/novasoar-tax/novasoar-tax-deploy.yaml"
                    
                    // 执行 K8s 部署
                    sh 'kubectl apply -f noval-helm/novasoar-tax/novasoar-tax-deploy.yaml'
                    
                    // （可选）如果你希望将更新后的 YAML 自动同步回配置仓库：
                    /*
                    sh '''
                        cd noval-helm
                        git config user.name "Jenkins CI"
                        git config user.email "jenkins@devops.com"
                        git add novasoar-tax/novasoar-tax-deploy.yaml
                        git commit -m "CI: update novasoar-tax image tag to ${BUILD_NUMBER}"
                        git push origin main
                    '''
                    */
                }
            }
        }
    }
}

pipeline {
    agent any
    tools {
        maven 'Maven-3.8.novalsoar'
    }
    stages {
       stage('1. 拉取代码') {
            steps {
                // 先彻底清空当前工作空间，防止残留文件导致非 Git 目录错误
                cleanWs()
                
                checkout([$class: 'GitSCM',
                    branches: [[name: 'main']],
                    userRemoteConfigs: [[
                        url: 'git@github.com:Edgarmongo/novasoar-tax.git',
                        credentialsId: 'github-ssh-cred' // 确认这里的凭证如果是 SSH 就用 ssh-cred，如果是之前换的 HTTPS 也可以对应修改
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
                    // 1. 使用 Git 插件拉取，并明确指定延伸目录为 noval-helm
                    checkout([$class: 'GitSCM',
                        branches: [[name: 'main']],
                        extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'noval-helm']],
                        userRemoteConfigs: [[
                            url: 'https://github.com/Edgarmongo/noval-helm.git',
                            credentialsId: 'github-https-cred'
                        ]]
                    ])
                    
                    // 2. 打印当前工作目录和文件列表，确保万无一失
                    sh 'pwd && ls -la noval-helm/novasoar-tax/'
                    
                    // 3. 替换 yaml 文件中的镜像版本号
                    sh "sed -i 's#__IMAGE_TAG__#${BUILD_NUMBER}#g' noval-helm/novasoar-tax/novasoar-tax-deploy.yaml"
                    
                    // 4. 执行 K8s 部署
                    sh 'kubectl apply -f noval-helm/novasoar-tax/novasoar-tax-deploy.yaml'
                }
            }
        }
    }
}

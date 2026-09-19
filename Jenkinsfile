pipeline {
    agent any
    tools {
        maven 'Maven-3.8.novalsoar' // 对应你在 Jenkins Tools 中配置的 Maven 名称
    }
    stages {
        stage('1. 拉取代码') {
            steps {
				// 使用 withCredentials 或者直接在 git 步骤中指定 credentialsId
				checkout([$class: 'GitSCM',
					branches: [[name: 'main']],
					userRemoteConfigs: [[
						url: 'https://github.com/Edgarmongo/novasoar-tax.git',
						credentialsId: 'github-cred' // 对应你在 Jenkins 里填写的凭证 ID
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
                    withCredentials([usernamePassword(credentialsId: 'harbor-cred', usernameVariable: 'admin', passwordVariable: 'Harbor12345')]) {
                        sh 'echo $PASS | docker login 192.168.0.152 -u $USER --password-stdin'
                        sh 'docker push 192.168.0.152/novasoar-tax/novasoar-tax:${BUILD_NUMBER}'
                    }
                }
            }
        }
    }
}
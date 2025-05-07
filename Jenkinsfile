pipeline {
    agent any

    environment {
        ECR_REPO = '123456789012.dkr.ecr.ap-northeast-2.amazonaws.com/my-app'
        IMAGE_TAG = "v${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/yourname/your-repo.git'
            }
        }

        stage('Build with Kaniko') {
            steps {
                script {
                    sh '''
                    mkdir -p /kaniko/.docker
                    echo "{\"credsStore\":\"ecr-login\"}" > /kaniko/.docker/config.json
                    
                    /kaniko/executor \
                      --dockerfile=Dockerfile \
                      --context=. \
                      --destination=${ECR_REPO}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Deploy with ArgoCD') {
            steps {
                script {
                    sh '''
                    argocd app sync my-app
                    '''
                }
            }
        }
    }
}
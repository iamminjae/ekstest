pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-northeast-2'
        ECR_REPO = '618465462717.dkr.ecr.ap-northeast-2.amazonaws.com/ekstest'
        ECR_REPOSITORY = 'ekstest-app'
        IMAGE_TAG = "v${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/iamminjae/ekstest.git'
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-creds']]) {
                    sh '''
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS --password-stdin $ECR_REGISTRY
                    '''
                }
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
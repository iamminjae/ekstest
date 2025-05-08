pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/iamminjae/ekstest.git'
        AWS_REGION = 'ap-northeast-2'
        ECR_REGISTRY = '618465462717.dkr.ecr.ap-northeast-2.amazonaws.com'
        ECR_REPOSITORY = 'ekstest-app'
        ECR_REPO = "${ECR_REGISTRY}/${ECR_REPOSITORY}"
        IMAGE_TAG = "v${BUILD_NUMBER}"
        ARGOCD_SERVER = "a70cc747b77414cdd90a94151ceab99c-1846804598.ap-northeast-2.elb.amazonaws.com"
        ARGOCD_USERNAME = "admin"
        ARGOCD_PASSWORD = "dmzCffGVFddZIC3w"
    }

    stages {
        stage('Checkout') {
            steps {
                git "${env.GIT_REPO}"
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

        // stage('Build & Push Image using Kaniko') {
        //     steps {
        //         sh '''
        //         mkdir -p /kaniko/.docker
        //         echo "{\"credsStore\":\"ecr-login\"}" > /kaniko/.docker/config.json

        //         /kaniko/executor \
        //           --dockerfile=Dockerfile \
        //           --context=. \
        //           --destination=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
        //         '''
        //     }
        // }
        stage('Build & Push Image using Kaniko') {
            steps {
                script {
                    sh '''
                    docker run --rm \
                    -v `pwd`:/workspace \
                    -v $HOME/.aws:/root/.aws:ro \
                    gcr.io/kaniko-project/executor:latest \
                    --dockerfile=Dockerfile \
                    --context=dir:///workspace \
                    --destination=$ECR_REPO:$IMAGE_TAG \
                    --insecure --skip-tls-verify
                    '''
                }
            }
        }

        // stage('Update Helm values.yaml') {
        //     steps {
        //         script {
        //             def file = readFile 'charts/ekstest-app/values.yaml'
        //             def updated = file.replaceAll(/tag: .*/, "tag: ${IMAGE_TAG}")
        //             writeFile file: 'charts/ekstest-app/values.yaml', text: updated
        //             sh '''
        //             git config --global user.email "you@example.com"
        //             git config --global user.name "Jenkins"
        //             git add charts/ekstest-app/values.yaml
        //             git commit -m "Update image tag to ${IMAGE_TAG}"
        //             git push origin master
        //             '''
        //         }
        //     }
        // }
        stage('Update Helm values.yaml') {
            steps {
                script {
                    def file = readFile 'charts/ekstest-app/values.yaml'
                    def updated = file.replaceAll(/tag: .*/, "tag: ${IMAGE_TAG}")
                    writeFile file: 'charts/ekstest-app/values.yaml', text: updated

                    withCredentials([usernamePassword(
                        credentialsId: 'github-token',
                        usernameVariable: 'GIT_USERNAME',
                        passwordVariable: 'GIT_PASSWORD'
                    )]) {
                        sh '''
                        git config user.email "you@example.com"
                        git config user.name "Jenkins"
                        git remote set-url origin https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/iamminjae/ekstest.git
                        git add charts/ekstest-app/values.yaml
                        git commit -m "Update image tag to ${IMAGE_TAG}" || echo "No changes to commit"
                        git push origin master
                        '''
                    }
                }
            }
        }

        stage('Deploy via ArgoCD') {
            // steps {
            //     sh '''
            //     argocd app sync ekstest-app
            //     '''
            // }
            script {
                // ArgoCD 로그인
                sh '''
                argocd login <ARGOCD_SERVER> --username <ARGOCD_USERNAME> --password <ARGOCD_PASSWORD> --insecure
                '''
                // 앱 동기화
                sh '''
                argocd app sync ekstest-app
                '''
            }
        }
    }
}

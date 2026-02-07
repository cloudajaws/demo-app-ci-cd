pipeline {
    agent any

    environment {
        AWS_REGION   = "us-west-2"
        ECR_REGISTRY = "066255739085.dkr.ecr.us-west-2.amazonaws.com"
        ECR_REPO     = "demo-app"
        CLUSTER      = "demo-cluster-v2"
        IMAGE_TAG    = "latest"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/cloudajaws/demo-app-ci-cd.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t ${ECR_REPO}:${IMAGE_TAG} .
                '''
            }
        }

        stage('Login to Amazon ECR') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'AKIAQ63JGLDG5BUSZR4G']
                ]) {
                    sh '''
                    aws ecr get-login-password --region ${AWS_REGION} \
                    | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                    '''
                }
            }
        }

        stage('Tag & Push Image to ECR') {
            steps {
                sh '''
                docker tag ${ECR_REPO}:${IMAGE_TAG} \
                ${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}

                docker push ${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'AKIAQ63JGLDG5BUSZR4G']
                ]) {
                    sh '''
                    aws eks update-kubeconfig \
                      --region ${AWS_REGION} \
                      --name ${CLUSTER}

                    kubectl apply -f k8s/deployment.yaml
                    '''
                }
            }
        }
    }
}

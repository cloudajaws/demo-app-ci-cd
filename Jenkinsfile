pipeline {
    agent any

    environment {
        AWS_REGION = "us-west-2"
        ECR_REPO   = "066255739085.dkr.ecr.us-west-2.amazonaws.com/demo-app"
        CLUSTER    = "demo-cluster-v2"
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
                sh 'docker build -t demo-app:latest .'
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'AKIAQ63JGLDG5BUSZR4G']
                ]) {
                    sh '''
                    aws ecr get-login-password --region $AWS_REGION \
                    | docker login --username AWS --password-stdin $ECR_REPO
                    '''
                }
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh '''
                docker tag demo-app:latest $ECR_REPO:latest
                docker push $ECR_REPO:latest
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
                      --region $AWS_REGION \
                      --name $CLUSTER

                    kubectl apply -f k8s/deployment.yaml
                    '''
                }
            }
        }
    }
}


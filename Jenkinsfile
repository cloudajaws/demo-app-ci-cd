pipeline {
    agent any

    environment {
        // AWS ECR details
        AWS_REGION = 'us-west-2'
        ECR_REPO = '066255739085.dkr.ecr.us-west-2.amazonaws.com/demo-app'
    }

    stages {

        stage('Checkout SCM') {
            steps {
                // Checkout code from GitHub
                git branch: 'main', url: 'https://github.com/cloudajaws/demo-app-ci-cd.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Tag Docker image with Jenkins build number
                    dockerImage = "demo-app:${env.BUILD_NUMBER}"
                    sh "docker build -t ${dockerImage} ."
                }
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                    credentialsId: 'AKIAQ63JGLDG5BUSZR4G'
                ]]) {
                    sh """
                        aws ecr get-login-password --region ${AWS_REGION} | \
                        docker login --username AWS --password-stdin ${ECR_REPO}
                    """
                }
            }
        }

        stage('Tag & Push Image to ECR') {
            steps {
                script {
                    dockerImageECR = "${ECR_REPO}:${env.BUILD_NUMBER}"
                    sh "docker tag ${dockerImage} ${dockerImageECR}"
                    sh "docker push ${dockerImageECR}"
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                    credentialsId: 'AKIAQ63JGLDG5BUSZR4G'
                ]]) {
                    sh """
                        # Update kubeconfig for EKS cluster
                        aws eks update-kubeconfig --region ${AWS_REGION} --name demo-cluster-v2
                        
                        # Deploy the new image using build number
                        kubectl set image deployment/demo-app demo-app=${ECR_REPO}:${env.BUILD_NUMBER} --record

                        # Optional: rollout status to wait until deployment completes
                        kubectl rollout status deployment/demo-app
                    """
                }
            }
        }

    }

    post {
        success {
            echo "Deployment successful! Running build number: ${env.BUILD_NUMBER}"
        }
        failure {
            echo "Deployment failed for build number: ${env.BUILD_NUMBER}"
        }
    }
}

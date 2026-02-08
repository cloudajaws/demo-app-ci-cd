pipeline {
    agent any
    environment {
        AWS_REGION = 'us-west-2'
        ECR_REPO = '066255739085.dkr.ecr.us-west-2.amazonaws.com/demo-app'
        BUILD_TAG = "${env.BUILD_NUMBER}" // Use Jenkins build number for tagging
    }
    stages {

        stage('Checkout Code') {
            steps {
                echo "\n===== CHECKOUT CODE ====="
                git branch: 'main', url: 'https://github.com/cloudajaws/demo-app-ci-cd.git'
            }
        }

        stage('Build Docker Image - DEV') {
            steps {
                echo "\n===== BUILD IMAGE FOR DEV (Build #${BUILD_NUMBER}) ====="
                sh """
                    docker build -t demo-app:dev-${BUILD_NUMBER} .
                """
            }
        }

        stage('Push Docker Image to ECR - DEV') {
            steps {
                echo "\n===== PUSH IMAGE TO ECR - DEV ====="
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                    credentialsId: 'AKIAQ63JGLDG5BUSZR4G' // Your Jenkins AWS credentials
                ]]) {
                    sh """
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO
                        docker tag demo-app:dev-${BUILD_NUMBER} $ECR_REPO:dev-${BUILD_NUMBER}
                        docker push $ECR_REPO:dev-${BUILD_NUMBER}
                    """
                }
            }
        }

        stage('Deploy to DEV') {
            steps {
                echo "\n===== DEPLOY TO DEV ====="
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                    credentialsId: 'AKIAQ63JGLDG5BUSZR4G'
                ]]) {
                    sh """
                        aws eks update-kubeconfig --region $AWS_REGION --name demo-cluster-v2
                        kubectl set image deployment/demo-app demo-app=$ECR_REPO:dev-${BUILD_NUMBER} --record
                    """
                }
            }
        }

        stage('Build Docker Image - TEST') {
            steps {
                echo "\n===== BUILD IMAGE FOR TEST (Build #${BUILD_NUMBER}) ====="
                sh """
                    docker build -t demo-app:test-${BUILD_NUMBER} .
                """
            }
        }

        stage('Push Docker Image to ECR - TEST') {
            steps {
                echo "\n===== PUSH IMAGE TO ECR - TEST ====="
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                    credentialsId: 'AKIAQ63JGLDG5BUSZR4G'
                ]]) {
                    sh """
                        docker tag demo-app:test-${BUILD_NUMBER} $ECR_REPO:test-${BUILD_NUMBER}
                        docker push $ECR_REPO:test-${BUILD_NUMBER}
                    """
                }
            }
        }

        stage('Deploy to TEST') {
            steps {
                echo "\n===== DEPLOY TO TEST ====="
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                    credentialsId: 'AKIAQ63JGLDG5BUSZR4G'
                ]]) {
                    sh """
                        aws eks update-kubeconfig --region $AWS_REGION --name demo-cluster-v2
                        kubectl set image deployment/demo-app demo-app=$ECR_REPO:test-${BUILD_NUMBER} --record
                    """
                }
            }
        }

        stage('Build Docker Image - PROD') {
            steps {
                echo "\n===== BUILD IMAGE FOR PROD (Build #${BUILD_NUMBER}) ====="
                sh """
                    docker build -t demo-app:prod-${BUILD_NUMBER} .
                """
            }
        }

        stage('Push Docker Image to ECR - PROD') {
            steps {
                echo "\n===== PUSH IMAGE TO ECR - PROD ====="
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                    credentialsId: 'AKIAQ63JGLDG5BUSZR4G'
                ]]) {
                    sh """
                        docker tag demo-app:prod-${BUILD_NUMBER} $ECR_REPO:prod-${BUILD_NUMBER}
                        docker push $ECR_REPO:prod-${BUILD_NUMBER}
                    """
                }
            }
        }

        stage('Deploy to PROD') {
            steps {
                echo "\n===== DEPLOY TO PROD ====="
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                    credentialsId: 'AKIAQ63JGLDG5BUSZR4G'
                ]]) {
                    sh """
                        aws eks update-kubeconfig --region $AWS_REGION --name demo-cluster-v2
                        kubectl set image deployment/demo-app demo-app=$ECR_REPO:prod-${BUILD_NUMBER} --record
                    """
                }
            }
        }

    }

    post {
        success {
            echo "\n===== PIPELINE COMPLETED SUCCESSFULLY ====="
        }
        failure {
            echo "\n===== PIPELINE FAILED ====="
        }
    }
}

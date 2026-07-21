pipeline {
    agent any
    tools {
        maven 'maven3.9.14'
        jdk 'java17'
    }
    environment {
        DOCKER_IMAGE = 'sher16/portfolio-app:latest'
        EKS_CLUSTER = 'mycompany-dev-eks'
        AWS_REGION = 'ap-south-1'
        NAMESPACE = 'default'
    }
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        stage('Build Application') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${env.DOCKER_IMAGE} ."
            }
        }
        stage('Push Docker Image to Docker Hub') {
            steps {
                withDockerRegistry(credentialsId: 'docker-hub-credentials', url: 'https://index.docker.io/v1/') {
                    sh "docker push ${env.DOCKER_IMAGE}"
                }
            }
        }
        stage('Deploy to EKS') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                        aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
                        aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
                        aws configure set default.region "$AWS_REGION"
                        aws eks update-kubeconfig --region "$AWS_REGION" --name "$EKS_CLUSTER"
                        kubectl get nodes
                        kubectl apply -f kubernetes/namespace.yaml
                        kubectl apply -f kubernetes/configmap.yaml
                        kubectl apply -f kubernetes/secret.yaml
                        kubectl apply -f kubernetes/deployment.yaml
                        kubectl apply -f kubernetes/service.yaml
                        kubectl apply -f kubernetes/hpa.yaml
                        kubectl apply -f kubernetes/ingress.yaml
                    '''
                }
            }
        }
    }
}

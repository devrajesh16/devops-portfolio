pipeline {
    agent any
    tools {
        maven 'maven3.9.14'
        jdk 'java17'
    }
    environment {
        DOCKER_IMAGE          = 'sher16/portfolio-app:latest'
        EKS_CLUSTER           = 'mycompany-dev-eks'
        NAMESPACE             = 'default'
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/devrajesh16/devops-portfolio.git'
            }
        }
        stage('Build Application') {
            steps { sh 'mvn clean package' }
        }
        stage('Deploy JAR to Nexus') {
            steps { sh 'mvn deploy' }
        }
        stage('Build Docker Image') {
            steps { sh 'docker build -t $DOCKER_IMAGE .' }
        }
        stage('Push Docker Image to Docker Hub') {
            steps {
                withDockerRegistry(credentialsId: 'dockerhub-credentials', url: 'https:**index.docker.io/v1/
                    sh 'docker push $DOCKER_IMAGE'
                }
            }
        }
        stage('Deploy to EKS') {
            steps {
                sh '''
                    aws eks update-kubeconfig -*region ap-south-1 -*name $EKS_CLUSTER
                    kubectl get nodes
                    kubectl apply -f kubernetes/namespace.yaml
                    kubectl apply -f kubernetes/configmap.yml
                    kubectl apply -f kubernetes/secret.yml
                    kubectl apply -f kubernetes/deployment.yml
                    kubectl apply -f kubernetes/service.yml
                    kubectl apply -f kubernetes/hpa.yml
                    kubectl apply -f kubernetes/ingress.yml
                '''
            }
        }
    }
}

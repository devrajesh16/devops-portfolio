pipeline {
    agent any

    tools {
        maven 'maven3.9.14'
        jdk 'java17'
    }

    environment {
        DOCKER_IMAGE = 'sher16/portfolio-app:latest'
        EKS_CLUSTER  = 'mycompany-dev-eks'
        AWS_REGION   = 'ap-south-1'
        NAMESPACE    = 'default'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-cred',
                    url: 'https://github.com/devrajesh16/devops-portfolio.git'
            }
        }

        stage('Build Application') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Deploy JAR to Nexus') {
            steps {
                sh 'mvn deploy'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials') {
                        sh 'docker push $DOCKER_IMAGE'
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds']
                ]) {

                    sh '''
                        aws sts get-caller-identity

                        aws eks update-kubeconfig \
                            --region $AWS_REGION \
                            --name $EKS_CLUSTER

                        kubectl get nodes

                        kubectl apply -f kubernetes/namespace.yaml
                        kubectl apply -f kubernetes/configmap.yaml
                        kubectl apply -f kubernetes/secret.yaml
                        kubectl apply -f kubernetes/deployment.yaml
                        kubectl apply -f kubernetes/service.yaml
                        kubectl apply -f kubernetes/hpa.yaml
                        kubectl apply -f kubernetes/ingress.yaml

                        kubectl get pods -n $NAMESPACE
                        kubectl get svc -n $NAMESPACE
                        kubectl get ingress -n $NAMESPACE
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline executed successfully.'
        }

        failure {
            echo 'Pipeline execution failed.'
        }

        always {
            cleanWs()
        }
    }
}

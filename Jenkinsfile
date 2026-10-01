pipeline {
    agent any
    
    environment {
        KUBECONFIG = credentials('eks-kubeconfig')
        HELM_RELEASE = 'frontend-service'
        NAMESPACE = 'production'
    }

    stages {
        stage('Provision Infrastructure') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        
        stage('Deploy via Helm') {
            steps {
                sh "helm upgrade --install ${HELM_RELEASE} ./helm-chart -n ${NAMESPACE} --wait"
            }
        }

        stage('Anomaly Health Check') {
            steps {
                // This script queries Prometheus. If it exits with 1, the pipeline fails.
                sh 'bash scripts/anomaly_health_check.sh'
            }
        }
    }

    post {
        failure {
            echo "Anomaly detected or deployment failed. Initiating automated Helm rollback."
            sh "helm rollback ${HELM_RELEASE} 0 -n ${NAMESPACE}"
            
            // Notify the engineering team
            slackSend (color: '#FF0000', message: "🚨 Deployment rolled back for ${HELM_RELEASE} due to metric anomalies.")
        }
        success {
            slackSend (color: '#00FF00', message: "✅ Deployment successful and verified for ${HELM_RELEASE}.")
        }
    }
}

pipeline {
    agent any
    stages {
        stage('Checkout from Git') {
            steps {
                git branch: 'main', url: 'https://github.com/yash509/AWS-EKS-Deployment-Pipeline.git'
            }
        }
        stage('Terraform version') {
            steps {
                sh 'terraform --version'
            }
        }
        stage('Terraform init') {
            steps {
                withCredentials([string(credentialsId: 'snyk', variable: 'snyk')]) {
                sh 'snyk auth $snyk'
                sh 'terraform init && snyk iac test --report > iacvulnerabilitiyreport.txt || true'
                // sh 'terraform init'
                }   
            }
        }
        stage('Terraform validate') {
            steps {
                sh 'terraform validate'
            }
        }
        stage('Terraform plan'){
             steps{
                sh 'terraform plan'
            }
        }
        stage('Terraform apply/destroy'){
             steps{
                 script {
                    sh 'terraform ${action} --auto-approve'
                }
            }
        }
    }
}

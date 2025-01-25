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
                sh 'terraform init'
            }
        }

        stage('Snyk IAC Vulnerability Test') {
            steps {
                withCredentials([string(credentialsId: 'snyk', variable: 'snyk')]) {
                    sh 'snyk auth $snyk'
                    sh 'terraform init && snyk iac test --report > IAC-vulnerabilityreport.txt || true'
                    sh 'snyk iac test backend.tf --report > IACBackend-filevulnerabilityreport.txt || true'
                }
            }
        }

        stage('Terraform validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform plan') {
            steps {
                sh 'terraform plan'
            }
        }

        stage('Terraform apply/destroy') {
            steps {
                script {
                    sh 'terraform ${action} --auto-approve'
                }
            }
        }
    }

    post {
        always {
            script {
                def jobName = env.JOB_NAME
                def buildNumber = env.BUILD_NUMBER
                def pipelineStatus = currentBuild.result ?: 'UNKNOWN'
                def bannerColor = pipelineStatus.toUpperCase() == 'SUCCESS' ? 'green' : 'red'
                def body = """
                <html>
                <body>
                <div style="border: 4px solid ${bannerColor}; padding: 10px;">
                <h2>${jobName} - Build ${buildNumber}</h2>
                <div style="background-color: ${bannerColor}; padding: 10px;">
                <h3 style="color: white;">Pipeline Status: ${pipelineStatus.toUpperCase()}</h3>
                </div>
                <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
                </div>
                </body>
                </html>
                """

                emailext (
                    attachLog: true,
                    subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus.toUpperCase()}",
                    body: body,
                    to: 'clouddevopshunter@gmail.com',
                    from: 'jenkins@example.com',
                    replyTo: 'jenkins@example.com',
                    mimeType: 'text/html',
                    attachmentsPattern: 'IAC-vulnerabilityreport.txt, IACBackend-filevulnerabilityreport.txt'
                )

                def buildDuration = currentBuild.durationString.replace(' and counting', '')
                def changes = currentBuild.changeSets.collect { changeSet ->
                    changeSet.items.collect { entry ->
                        "*${entry.author}:* ${entry.msg} (${entry.commitId})"
                    }.join('\n')
                }.join('\n')

                def buildUser = env.BUILD_USER ?: 'N/A'
                def buildUserEmail = env.BUILD_USER_EMAIL ?: 'N/A'

                slackSend(
                    channel: '#cloud_devsecops_engineer',
                    color: currentBuild.currentResult == 'SUCCESS' ? 'good' : 'danger',
                    message: """
                    *${currentBuild.currentResult}:* Job ${env.JOB_NAME} (${env.BUILD_NUMBER})
                    *Duration:* ${buildDuration}
                    *Started by:* ${currentBuild.getBuildCauses()[0].shortDescription}
                    *User Email:* ${env.BUILD_USER_EMAIL}
                    *Changes:*
                    ${changes}
                    *Workspace:* ${env.WORKSPACE}
                    *Node:* ${env.NODE_NAME}
                    *Jenkins URL:* ${env.JENKINS_URL}
                    *Executor Number:* ${env.EXECUTOR_NUMBER}
                    *Job URL:* ${env.JOB_URL}
                    *Build URL:* ${env.BUILD_URL}
                    *Build Timestamp:* ${new Date(currentBuild.startTimeInMillis).format("yyyy-MM-dd HH:mm:ss")}
                    *Build Parameters:* ${params}
                    *Build ID:* ${env.BUILD_ID}
                    *Build Tag:* ${env.BUILD_TAG}
                    *Build Display Name:* ${currentBuild.displayName}
                    *Build Executor:* ${env.EXECUTOR_NUMBER}
                    *Slave/Node Name:* ${env.NODE_NAME}
                    *Node Labels:* ${env.NODE_LABELS}
                    """
                )
            }
        }
    }
}

pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
    }

    stages {

        stage('Create Dynamic Inventory') {
            steps {
                sh '''
                echo "[splunk]" > dynamic_inventory.ini
                echo "${INSTANCE_IP}" >> dynamic_inventory.ini
                '''
            }
        }

        stage('Wait for EC2 Health') {
            steps {
                sh '''
                aws ec2 wait instance-status-ok --instance-ids ${INSTANCE_ID}
                '''
            }
        }

        stage('Install Splunk') {
            steps {
                ansiblePlaybook(
                    playbook: 'playbooks/splunk.yml',
                    inventory: 'dynamic_inventory.ini'
                )
            }
        }

        stage('Test Splunk') {
            steps {
                ansiblePlaybook(
                    playbook: 'playbooks/test-splunk.yml',
                    inventory: 'dynamic_inventory.ini'
                )
            }
        }

        stage('Validate Destroy') {
            steps {
                input message: 'Destroy infrastructure?'
            }
        }

        stage('Terraform Destroy') {
            steps {
                sh '''
                cd terraform
                terraform destroy -auto-approve
                '''
            }
        }
    }

    post {
        always {
            sh 'rm -f dynamic_inventory.ini'
        }
        failure {
            sh 'cd terraform && terraform destroy -auto-approve'
        }
        aborted {
            sh 'cd terraform && terraform destroy -auto-approve'
        }
    }
}

def ansible_server_private_ip = "172.31.13.197"
def kubernetes_server_private_ip = "172.31.14.147"

node {

    stage('Git Checkout') {
        git branch: 'main',
            url: 'https://github.com/gelazog/DevOps-Project-Build.git'
    }

    stage('Send files to Ansible Server') {
        sshagent(['ansible-server']) {
            sh """
            scp -o StrictHostKeyChecking=no -r * \
            ubuntu@${ansible_server_private_ip}:/home/ubuntu/
            """
        }
    }

    stage('Docker Build on Ansible Server') {
        sshagent(['ansible-server']) {
            sh """
            ssh -o StrictHostKeyChecking=no ubuntu@${ansible_server_private_ip} '
            cd /home/ubuntu &&
            docker build -t ${JOB_NAME}:v-${BUILD_ID} . &&
            docker tag ${JOB_NAME}:v-${BUILD_ID} 0322103737/${JOB_NAME}:v-${BUILD_ID} &&
            docker tag ${JOB_NAME}:v-${BUILD_ID} 0322103737/${JOB_NAME}:latest
            '
            """
        }
    }

    stage('Push Docker Images to DockerHub') {
        sshagent(['ansible-server']) {
            withCredentials([string(credentialsId: 'dockerhub_passwd1', variable: 'DOCKER_PASS')]) {
                sh """
                ssh -o StrictHostKeyChecking=no ubuntu@${ansible_server_private_ip} '
                docker login -u 0322103737 -p ${DOCKER_PASS} &&
                docker push 0322103737/${JOB_NAME}:v-${BUILD_ID} &&
                docker push 0322103737/${JOB_NAME}:latest &&
                docker rmi 0322103737/${JOB_NAME}:v-${BUILD_ID} 0322103737/${JOB_NAME}:latest ${JOB_NAME}:v-${BUILD_ID}
                '
                """
            }
        }
    }

    stage('Send files to Kubernetes Server') {
        sshagent(['kubernetes-server']) {
            sh """
            scp -o StrictHostKeyChecking=no -r * \
            ubuntu@${kubernetes_server_private_ip}:/home/ubuntu/
            """
        }
    }

    stage('Deploy to Kubernetes using Ansible') {
        sshagent(['ansible-server']) {
            sh """
            ssh -o StrictHostKeyChecking=no ubuntu@${ansible_server_private_ip} '
            cd /home/ubuntu &&
            ansible -m ping webnode &&
            ansible-playbook deploy.yml
            '
            """
        }
    }
}

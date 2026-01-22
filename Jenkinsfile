def ansible_server_private_ip = "172.31.13.197"
def kubernetes_server_private_ip = "172.31.3.209"

node {

    stage('Git Checkout') {
        git branch: 'main',
            url: 'https://github.com/khalifemubin/devops-project-one.git'
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
            docker tag ${JOB_NAME}:v-${BUILD_ID} khalifemubin/${JOB_NAME}:v-${BUILD_ID} &&
            docker tag ${JOB_NAME}:v-${BUILD_ID} khalifemubin/${JOB_NAME}:latest
            '
            """
        }
    }

    stage('Push Docker Images to DockerHub') {
        sshagent(['ansible-server']) {
            withCredentials([string(credentialsId: 'dockerhub_passwd1', variable: 'DOCKER_PASS')]) {
                sh """
                ssh -o StrictHostKeyChecking=no ubuntu@${ansible_server_private_ip} '
                docker login -u khalifemubin -p ${DOCKER_PASS} &&
                docker push khalifemubin/${JOB_NAME}:v-${BUILD_ID} &&
                docker push khalifemubin/${JOB_NAME}:latest
                '
                """
            }
        }
    }

    stage('Deploy to Kubernetes using Ansible') {
        sshagent(['ansible-server']) {
            sh """
            ssh -o StrictHostKeyChecking=no ubuntu@${ansible_server_private_ip} '
            cd /home/ubuntu &&
            ansible-playbook deploy.yml
            '
            """
        }
    }
}

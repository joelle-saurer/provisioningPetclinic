pipeline{
    
    agent any
 
    tools {
        maven "Maven"
       
    }

    stages {   
        stage('Release production image') {
            steps{ 
                                 
                ansiblePlaybook credentialsId: 'private-key', installation: 'Ansible', inventory: '/var/lib/jenkins/workspace/petProduction/ansible/Production/inventory.yml', playbook: '/var/lib/jenkins/workspace/petProduction/ansible/Production/production.yml'
            }
        }

    }
}
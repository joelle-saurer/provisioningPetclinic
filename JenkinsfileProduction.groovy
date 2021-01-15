pipeline{
    
    agent any
 
    tools {
        maven "Maven"
    }

    stages {   
        stage('Release production image') {
            steps{ 
                        echo 'Tests are completed, release as production image'
                
                        sh 'cd /home/azureuser/Provisioning/ansible/production/; ansible-playbook production.yml'
            }
        }

    }
}
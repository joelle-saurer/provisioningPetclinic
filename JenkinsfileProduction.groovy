pipeline{
    
    agent any
 
    tools {
        maven "Maven"
     
    }

    stages {  

        stage('Release production image') {
            steps{ 
                        echo 'Tests are completed, release as production image'
                
                        sh 'cd /var/lib/jenkins/workspace/petProduction/ansible/Production/; ansible-playbook production.yml'
            }
        }

    }
}
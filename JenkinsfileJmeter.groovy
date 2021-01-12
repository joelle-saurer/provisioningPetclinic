pipeline {
    
    agent any
 
    tools {
        maven "Maven"
    }
 
    stages {
        stage('Launch petclinic') { 
            steps {
                echo 'Starting the AWS dev server using ansible tool'
           
                sh 'cd /home/azureuser/Provisioning/ansible/; ansible-playbook playbook.yml'

              }
        }
                
        stage('Run JMeter test') {
            steps {
            
              sh '/opt/jmeter/apache-jmeter-5.4/bin/jmeter -n -t /home/azureuser/petclinic/spring-framework-petclinic/LoadTestPet.jmx -l /var/lib/jenkins/workspace/jmeterTest/src/test/jmeter/LoadTestResult.jtl' 
             
              sh 'echo Test completed'
              sh 'echo Publish JMeter reports'

              perfReport '/var/lib/jenkins/workspace/jmeterTest/src/test/jmeter/LoadTestResult.jtl' 
            }
        }
     }

}

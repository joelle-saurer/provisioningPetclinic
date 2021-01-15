pipeline{
    
    agent any
 
    tools {
        maven "Maven"
    }

    stages {   
        stage('Startup virtual machine with Terraform') {
            steps{ 
                sh 'cd /home/azureuser/Provisioning/Terraform/; terraform init; terraform apply -auto-approve'
            }
        }

        stage('Launch petclinic') { 
            parallel{
                stage('create dev environment') { 
                    steps {
                        echo 'provision dev env and run app'
                
                        sh 'cd /home/azureuser/Provisioning/ansible/; ansible-playbook main.yml'

                    }
                }
               
                stage('Run Jmeter Test') { 
                    steps {
                        sh '/opt/jmeter/apache-jmeter-5.4/bin/jmeter -n -t /home/azureuser/petclinic/spring-framework-petclinic/LoadTestPet.jmx -l /var/lib/jenkins/workspace/jmeterTest/src/test/jmeter/LoadTestResult.jtl' 
             
                        sh 'echo Test completed'
                        sh 'echo Publish JMeter reports'

                        perfReport '/var/lib/jenkins/workspace/jmeterTest/src/test/jmeter/LoadTestResult.jtl' 
                    }
                }    
            }         
        } 

        stage('Destroy Terraform VM') { 
            steps{
                sh 'cd /home/azureuser/Provisioning/Terraform/; terraform destroy -auto-approve'
            }
        }     
    }
}

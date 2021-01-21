pipeline{
    
    agent any
 
    tools {
        maven "Maven"
    }

    stages {   
        stage('Startup virtual machine with Terraform') {
            steps{ 
                sh 'cd /home/joelle/provisioning/Terraform/; terraform init; terraform apply -auto-approve'
            }
        }

        stage('Run Jmeter Test') { 
                    steps {
                        sh '/opt/jmeter/apache-jmeter-5.4/bin/jmeter -n -t /home/joelle/provisioning/WebPerfPet.jmx -l /var/lib/jenkins/workspace/jmeterTest/src/test/jmeter/LoadTestResult.jtl' 
             
                        sh 'echo Test completed'
                        sh 'echo Publish JMeter reports'

                        perfReport '/var/lib/jenkins/workspace/jmeterTest/src/test/jmeter/LoadTestResult.jtl' 
                    }
                }    
            }         
        } 

        stage('Destroy Terraform VM') { 
            steps{
                sh 'cd /home/joelle/provisioning/Terraform/; terraform destroy -auto-approve'
            }
        }     
    }
}

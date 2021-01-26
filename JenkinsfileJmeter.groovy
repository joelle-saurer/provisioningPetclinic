pipeline{
    
    agent any
 
    tools {
        maven "Maven"
    }

    stages {   
        stage('Startup virtual machine with Terraform') {
            steps{ 
                sh 'cd /home/joelle/provisioning/Terraformjmeter/; terraform init; terraform apply -auto-approve'
            }
        }

        stage('Run Jmeter Test') { 
                    steps {
                        sh '/opt/jmeter/apache-jmeter-5.4/bin/jmeter -n -t /var/lib/jenkins/workspace/jmeterProvisioning/WebPerfPet.jmx -l /var/lib/jenkins/workspace/jmeterProvisioning/src/test/jmeter/LoadTestResult.jtl' 
             
                        sh 'echo Test completed'
                        sh 'echo Publish JMeter reports'

                        perfReport '/var/lib/jenkins/workspace/jmeterProvisioning/src/test/jmeter/LoadTestResult.jtl' 
                    }
                }    
            }         
        } 

        stage('Destroy Terraform VM') { 
            steps{
                sh 'cd /home/joelle/provisioning/Terraformjmeter/; terraform destroy -auto-approve'
            }
        }     
    }
}

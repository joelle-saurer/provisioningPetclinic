pipeline{
    
    agent any
 
    tools {
        maven "Maven"
        terraform "Terraform"
    }

    stages {   
        stage('Startup virtual machine with Terraform') {
            steps{ 
         
                sh 'cd /var/lib/jenkins/workspace/jmeterProvisioning/Terraformjmeter/; terraform init; terraform apply -auto-approve'
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

        stage('Destroy Terraform VM') { 
            steps{
                sh 'cd /var/lib/jenkins/workspace/jmeterProvisioning/Terraformjmeter/; terraform destroy -auto-approve'
            }
        }     
    }
}

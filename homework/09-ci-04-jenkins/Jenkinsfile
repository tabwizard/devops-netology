pipeline{
    agent {
      label 'linux'
    }
    stages{
        stage('Checkout repo'){
            steps{
                git credentialsId: 'wizard', url: 'git@github.com:tabwizard/kibana-role.git'
            }
        }
        stage('Install molecule'){
            steps{
                sh 'pip3 install -r test-requirements.txt'
            }
        }
        stage('Molecule test'){
            steps{
                sh 'molecule test'
            }
        }
    }
}
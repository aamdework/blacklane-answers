pipeline {
    agent { docker { image 'python:3.8.0-alpine' } }

    triggers {
        pollSCM('*/5 * * * 1-5')
    }
    options {
        skipDefaultCheckout(true)
        // Keep the 10 most recent builds
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
    }

    stages {
            stage ("Code pull"){
                steps{
                    checkout scm
                }
            }

            stage('build') {
                steps {
                    sh 'pip install -r requirements.txt'
                }
            }
            stage('Test environment') {
                steps {
                    sh ''' 
                      pip list
                      which pip
                      which python
                    '''
                }
            }
    }
    post {
        always {
            echo "always"
        }
        failure {
            echo "Send e-mail, when failed"
        }
    }
}
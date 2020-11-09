pipeline {
    agent { docker { image 'python:3.8.0-alpine' } }

    triggers {
        pollSCM('*/5 * * * 1-5')
    }

    options {
        skipDefaultCheckout(true)
        timestamps()
    }
    environment {

        APP_CURRENT_VERSION = "unset"

    }

    stages {

        stage ("pull code change"){
            steps{
                checkout scm
            }
        }
        stage('Build environemnt') {
            steps {
                echo "Building environemnt"
                sh 'pip install -r requirements.txt'
                sh 'pip install -r requirements.test.txt'
            }
        }

        stage('Static code metrics') {
            steps {

                echo "Code style check"
                sh 'flake8 app.py'

                echo "Static typing check"
                sh 'mypy app.py'

                echo "Test Coverage"
                sh 'coverage run'
            }
        }

        stage('Build package') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                sh  'python setup.py bdist_wheel'

            }
        }
        stage('Database Migrations') {

            steps {
                echo "Performing Database Migration"
                sh 'flask db upgrade'
            }
        }

        stage("Deploy to PyPI") {
            steps {
                sh "twine upload dist/*"
            }
        }

    }


post {
    success {
        script {
            APP_CURRENT_VERSION =  getVersion('version.txt')
            updateVersion('version.txt', APP_CURRENT_VERSION)
            credential.setEmail()
           }
        emailext (
                subject: "New build version '${APP_CURRENT_VERSION}' deployed. - [SUCCESS]",
                body: """<p>SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
                         <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>"""
        )
    }
    failure {
        emailext (
                subject: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: """<p>FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
                         <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>"""
        )
    }
}
}
void updateVersion(String fileName, String currentVersion) {

    if(!currentVersion.isEmpty()) {
        int buildNumberIdx = currentVersion.lastIndexOf(".")

        int NewBuildNumber = 0

        try {

            NewBuildNumber = Integer.parseInt(currentVersion.substring(buildNumberIdx + 1)) + 1

        } catch (NumberFormatException ex) {

            throw (new RuntimeException("Unable to increment current build number for current version ${currentVersion}. Error: ${ex.message}"))
        }

        def buildVersion = "${currentVersion.substring(0, buildNumberIdx)}.${NewBuildNumber}"

        def newVersion = buildVersion + "\n"

        step.writeFile file: fileName, text: newVersion
    }
    step.sh """#!/bin/sh  
           
            
            export GIT_USER_PASSWORD="${env.GIT_USER_PASSWORD}" 
            export GIT_USER_USERNAME='"""+env.GIT_USERNAME+"""' 
            pwd 
            git config --global user.name "${env.GIT_USERNAME}"
            git checkout -B ${env.BRANCH}  
            git add . 
            git commit -m "Jenkins Version Update" 
            git pull origin ${env.BRANCH}             
            for i in {1..5}; do git push origin ${env.BRANCH}  && break || sleep 15; done            
            """
}

String getVersion(String fname)
{
    def version =""
    new File(fname).withReader { version = it.readLine() }
    return version
}
# Hello

# Introduction

In this repository , i have added codes for containerization , ci/cd and bash scripts to orchestrate the various deployment related tasks.
The easiest way to start the app is to run `docker-compose up` in the project directory. I have also added a Jenkins file  for jenkins pipe line.
I have provided two version of going  about doing that tasks. The first batch is in the  project root and the second is  in a directory named platfrom in the project root.
One does not need both , my attempt to showing how one can go about achieving the tasks. 

# Tools and Technologies

- Jenkins 
- Bash
- Helm
- Docker
- Jenkins docker plugin

## Files description

- `Dockerfile` - docker file for containerization 
- `docker-compose.yml ` - docker compose file to start application and postgres db 
- `entrypoint.sh` - copied and used as an entry point
- `Jenkinsfile ` - Jenkins pipeline file 
- `platfrom` - directory with all the ci cd and containerization code. An attempt to collect all platfrom related code in one place. 
- `platfrom/docker` - directory with all the containerization code. Execution begins with make-image.sh 
- `platfrom/jenkins` - directory with all the CI/CD code. Contains two variations of a pipeline.  
- `platfrom/k8s` - directory with all  kubernetes code. 
- `platfrom/build-and-deploy.sh` - a utility script to build and deploy application
- `platfrom/increment-version.sh` - a utility script to update application version.



## Installation

To run the application on any developer machine , one has two options:
`gave to options- the first is the easy to use with all the code in the project dir and the secodnd platfrom/docker option keeps the code separate and make it easy to use both in dev and ci/cd options`
- Run `docker-compose up` in the project root. this will spin two containers up.
or 
- Run `./make-image.sh and then docker-compose up in platfrom/docker`

## Accessing the deployed application

- `http://localhost:5555/` - main page with all data shown
- `http://localhost:5555/version` -JSON response with current application version

## Infrastructure as Code

Using [Terraform] or [Cloudformation], or your IaC tool of choice. Feel free to include configuration management, if inclined.
The solution should be able to be deployed without human interaction and ideally on AWS.

- [ ] Start all instances
- [ ] Make required changes in OS
- [ ] Install Docker

## Containerization

Two versions of `Dockerfile`. Giving options here. One does not need both . One can user either of the two
Docker file in project root

```# pull official base image
   FROM python:3.8.0-alpine
   
   # set work directory
   WORKDIR /usr/src/app
   
   # set environment variables
   ENV PYTHONDONTWRITEBYTECODE 1
   ENV PYTHONUNBUFFERED 1
   
   RUN apk update && apk add postgresql-dev gcc python3-dev musl-dev
   
   # install dependencies
   RUN pip install --upgrade pip
   COPY ./requirements.txt /usr/src/app/requirements.txt
   RUN export LDFLAGS="-L/usr/local/opt/openssl/lib"
   RUN pip install -r requirements.txt
   
   # copy project
   COPY . /usr/src/app/
   
   EXPOSE 5000
   
   ENTRYPOINT ["./entrypoint.sh"]

```

and second option used by the util script 

```# pull official base image
   FROM python:3.8.0-alpine
   
   # set work directory
   WORKDIR /usr/src/app
   
   # set environment variables
   ENV PYTHONDONTWRITEBYTECODE 1
   ENV PYTHONUNBUFFERED 1
   
   RUN apk update && apk add postgresql-dev gcc python3-dev musl-dev
   
   # install dependencies
   RUN pip install --upgrade pip
   # copy project. Assumes all the files needed to build the image are copied to the docker/target folder using make-image.sh
   COPY target /usr/src/app/ 
   RUN export LDFLAGS="-L/usr/local/opt/openssl/lib"
   RUN pip install -r requirements.txt
   
   EXPOSE 5000
```
The corresponding `docker-compose.yml`
```
version: '3.6'

services:
  devops_interview_app:
    build: .
    depends_on:
      - postgres_db
    environment:
      USER_NAME: Abebe
      USER_URL: interview
      DATABASE_URL: postgresql+psycopg2://test:test@postgres_db/test
    networks:
      - default
    ports:
      - 5555:5555
    volumes:
      - ./migrations:/usr/src/app/migrations
    restart: always

  postgres_db:
    environment:
      POSTGRES_DB: test
      POSTGRES_USER: test
      POSTGRES_PASSWORD: test
    image: postgres:latest
    networks:
      - default
    ports:
      - 5405:5432
    restart: always
    volumes:
      - ./postgres-data:/var/lib/postgresql/data


```
## Continuous Integration/Deployment
Here also, i have provided two different version 
A pipeline using docker agent 
`Jenkinsfile`
```pipeline {
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

```

and a second Jenkins pipeline definition using bash utility scripts (founder under platfrom\jenkins folder)
```
 pipeline {

        agent any

        environment {
            APP_CURRENT_VERSION = "unset"
        }

        stages {

            stage("Build") {
                steps {
                    container('python:3.8.0-alpine + pip install -r requirements.tx') {
                    sh  '''
                    #!/bin/sh -e

                    cd docker
                    ./make-image.sh -r \${registry}
                    ./push-image.sh -r \${registry}
                     '''
                    }
                }
            }

            stage("Test") {
                steps {
                    container('python:3.8.0-alpine + pip install -r requirements.tx') {
                    sh 'pip install -r requirements.test.txt'
                    echo "Code style check"
                    sh 'flake8 app.py'
                    echo "Static typing check"
                    sh 'mypy app.py'
                    echo "Test Coverage"
                    sh 'coverage run'
                    }
                }
            }

            stage("DB_Migration") {
                steps {
                    container('python:3.8.0-alpine + pip install -r requirements.tx') {
                        sh 'flask db upgrade'
                    }
                }
            }

            stage("publish") {
                steps {
                    container('python:3.8.0-alpine + pip install -r requirements.tx') {
                    sh "twine upload dist/*"
                    }
                }
            }

             stage("deploy") {
                 steps {
                     container('python:3.8.0-alpine + pip install -r requirements.tx') {
                     sh '''
                         #!/bin/sh -e

                         cd docker/k8s
                         ./deploy.sh -e \${ENVIRONMENT}
                     '''
                      }
                 }
             }

        }

        post {
            success {
                container('python:3.8.0-alpine + pip install -r requirements.tx') {
                    script {
                    sh '''
                    ../increment-version.sh
                    '''
                    }
                }
            }
        }
    }

```

    
## Monitoring

The flask application can be monitored using the various tools out there. Examples of tools and metrics to moniro

- If using `prometheus` , we can use `prometheus flask exporter` and monitor things like:
    
    - Requests per time interval
    - Average response time
    - Request duration
    - Total requests per time interval
    - Memory usage
    - Cpu usage
    - Errors per time interval

The postgres database can be monitored using the various tools out there. Examples of tools and metrics to moniro
- If using `prometheus` , we can use `prometheus sql exporter` and monitor things like:

    - Cpu usage 
    - Memory usage 
    - Disk usage
    - Long running scripts 
    - Active db connection count
    - Active user session count
    - Database latency 
    - Database read latency 
    - Database write latency 


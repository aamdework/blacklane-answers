# Hello

# Introduction

Deploy the clones :) 

Thank you for interviewing with Blacklane. If you're here, it means we'd
like to understand your development process and understanding of SLDC.

To get started, please ***[mirror this repo](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/duplicating-a-repository#mirroring-a-repository), change the repository name, then begin work***. Mirroring instead of forking as well as renaming are recommended for privacy concerns. Spend as much much time
you feel is reasonable. It doesn’t matter if the project is "complete", nothing ever is.

# Application

All files you need are in this GitHub repository.

This app is written in Python.
Also, this task is not about programming, so if you don't know Python and are skilled in Bash, it's ok.

Requirements:

- Python `3.6` (any other `3.x` should work too)
- PostgreSQL server
- Packages listed in `requirements.txt` 

This application counts unique visitors and uses a database to persist data.

Application endpoints:

- `/` - main page with all data shown
- `/version` - JSON response with current application version

## Files description

- `migrations` - directory with database migrations (see _Installation_) based on `alembic`
- `static` - just static files for serving UI
- `templates` - HTML template for main page
- `app.py` - main "executable" which contains all code
- `requirements.txt` - list of all Python packages needed to run the application
- `requirements.test.txt` - list of all Python packages needed for CI/CD tasks
- `version.txt` - text file with current version

## Installation

To install the application, follow these steps:

- Prepare a PostgreSQL database
- Install all required packages with `pip install -r requirements.txt`
- Set all required environment variables
- Apply all migrations with `flask db upgrade`
- Start application

For the last step, you can use different approaches - just choose one from [official docs][flask-deploy].

## Configuration

Generic Docker-ready applications can be easily configured via environment variables.

- `DATABASE_URL` (required) - connection string to your database, you can find examples [here][flask-sqlalchemy-connstr].
- `USER_NAME` - your name, which will be shown on the page
- `USER_URL` - some kind of personal URL

# Task

Ideally, include all infrastructure-related code, scenarios, diagrams, and documentation as a main `README.md` file.

Feel free to choose what you'd like to integrate and reflect your best.

## Infrastructure as Code

Using [Terraform] or [Cloudformation], or your IaC tool of choice. Feel free to include configuration management, if inclined.
The solution should be able to be deployed without human interaction and ideally on AWS.

- [ ] Start all instances
- [ ] Make required changes in OS
- [ ] Install Docker

## Containerization

Create a `Dockerfile` to containerize the application.

- [ ] Choose a lightweight base image
- [ ] Include all installation steps
- [ ] Make this application run and listen on the HTTP port
- [ ] Prepare a `docker-compose.yml` for the application stack

## Testing 

All tools you need for this section are in `requirements.test.txt` file,
which can be easily installed with `pip install -r requirements.test.txt`.

- [ ] Linting
    - [ ] Code style<br/>
        Just use [flake8] and configuration from `setup.cfg`
    - [ ] Static typing<br/>
        This project can be verified with [mypy] static types checker, configuration for it can be found in `setup.cfg`
- [ ] Tests<br/>
    Can be run with `pytest.`
- [ ] Code coverage<br/>
    Checkout Python [Coverage] project, 
    or, you can get integration with [CodeCov] or [Coveralls] - they have free tiers.

## Continuous Integration/Deployment

At this stage the project should be functioning and you are ready to automate it.

Choose your favorite CI/CD:

- [ ] GitLab<br/>
    - `.gitlab-ci.yml` file as described [here][gitlab-ci-yml].
- [ ] Jenkins<br/>
    Create a declaritive pipeline using a `Jenkinsfile`.
    Documentation about Jenkins Pipelines is avaiable [here][jenkins-pipelines].

CI/CD additions:

- [ ] Database Migrations<br/>
    The application should perform DB migrations on each deployment.
- [ ] Versioning<br/>
    The current project version can be found in the file `version.txt`, and it will be shown on the web UI.
    
## Monitoring

Examples of how this application could be monitored.

## Documentation

Documentation should include:

- [ ] What technologies were used and what tools are needed to use your solution?
- [ ] How to start this service from the ground up, using your solution?

Also, you may write additional docs like:

- [ ] How to scale number of instances to take more load?
- [ ] Application deployment architecture diagram?

To draw diagrams you can use [Draw.io][drawio], [CloudCraft] or even [ASCII Art][asciiflow]. Include them in your repository too.

## Fixes?

There are some problems in app architecture. If you have a solution, it will be great!

# Questions?

If you still have some questions about this task, feel free to reach out.

# License

[![Creative Commons License](https://i.creativecommons.org/l/by-sa/4.0/88x31.png)][license]
This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License][license].
Adapted from https://github.com/soar/devops-test.

[github-clone]: git@github.com:blacklane/devops-interview.git
[github-repository]: https://github.com/blacklane/devops-interivew

[license]: http://creativecommons.org/licenses/by-sa/4.0/

[ansible]: https://www.ansible.com
[aws]: https://aws.amazon.com
[chef]: https://www.chef.io
[asciiflow]: http://asciiflow.com
[cloudcraft]: https://cloudcraft.co
[codecov]: https://codecov.io
[coverage]: https://coverage.readthedocs.io
[coveralls]: https://coveralls.io
[drawio]: http://draw.io
[flake8]: http://flake8.pycqa.org/en/latest/index.html
[flask]: http://flask.pocoo.org
[flask-deploy]: http://flask.pocoo.org/docs/1.0/deploying/#deployment
[flask-sqlalchemy-connstr]: http://flask-sqlalchemy.pocoo.org/2.3/config/#connection-uri-format
[gitlab-ci-yml]: https://docs.gitlab.com/ee/ci/yaml/
[iac]: https://en.wikipedia.org/wiki/Infrastructure_as_code
[jenkins-pipelines]: https://jenkins.io/doc/book/pipeline/
[mypy]: https://mypy.readthedocs.io/en/stable/index.html
[terraform]: https://www.terraform.io
[cloudformation]: https://aws.amazon.com/cloudformation/

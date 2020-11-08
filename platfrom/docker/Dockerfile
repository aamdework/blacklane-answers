# pull official base image
FROM python:3.8.0-alpine

# set work directory
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apk update && apk add postgresql-dev gcc python3-dev musl-dev

# install dependencies
RUN pip install --upgrade pip
# copy project
COPY target /usr/src/app/
RUN export LDFLAGS="-L/usr/local/opt/openssl/lib"
RUN pip install -r requirements.txt

EXPOSE 5000

ENTRYPOINT ["./entrypoint.sh"]

#ENTRYPOINT ["/bin/bash", "-c", "entrypoint.sh"]
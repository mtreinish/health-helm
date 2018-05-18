FROM python:alpine3.6

RUN apk update
RUN apk add --virtual build-deps gcc musl-dev g++ curl
RUN apk --no-cache add postgresql-dev linux-headers libxml2-dev

RUN pip install -U psycopg2
RUN pip install -U subunit2sql


RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.10.0/bin/linux/amd64/kubectl
RUN install -m 755 kubectl /usr/bin

COPY run_db_migrations.sh /root/run_db_migrations.sh

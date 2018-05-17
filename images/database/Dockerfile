FROM python:alpine3.6

RUN apk update
RUN apk add --virtual build-deps gcc musl-dev g++
RUN apk --no-cache add postgresql-dev linux-headers libxml2-dev

RUN pip install -U psycopg2
RUN pip install -U subunit2sql

COPY run_db_migrations.sh /root/run_db_migrations.sh

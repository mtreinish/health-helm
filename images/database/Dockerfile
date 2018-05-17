FROM python:alpine3.6

RUN apk update
RUN apk add --virtual build-deps gcc musl-dev
RUN apk --no-cache add postgresql-dev

RUN pip install -U psycopg2
RUN pip install -U subunit2sql

COPY run_db_migrations.sh /root/run_db_migrations.sh

RUN /root/run_db_migrations.sh

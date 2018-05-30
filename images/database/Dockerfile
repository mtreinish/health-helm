FROM python:stretch

RUN apt-get update
RUN apt-get install -y build-essential musl-dev curl
RUN apt-get install -y libpq-dev linux-headers-amd64 libxml2-dev

RUN pip install -U psycopg2
RUN pip install -U subunit2sql


RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.10.0/bin/linux/amd64/kubectl
RUN install -m 755 kubectl /usr/bin

COPY run_db_migrations.sh /root/run_db_migrations.sh

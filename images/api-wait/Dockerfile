FROM debian:latest

RUN apt-get update
RUN apt-get install -y curl

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.10.0/bin/linux/amd64/kubectl
RUN install -m 755 kubectl /usr/bin

COPY setvalue.sh /root/setvalue.sh

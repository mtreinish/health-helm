FROM alpine:latest

RUN apk update
RUN apk add --virtual curl

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.10.0/bin/linux/amd64/kubectl
RUN install -m 755 kubectl /usr/bin

COPY setvalue.sh /root/setvalue.sh

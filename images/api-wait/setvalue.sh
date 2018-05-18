#!/bin/sh

set -x

for i in {1..300}; do
    API_HOST=$(/usr/bin/kubectl get svc ${API_CONTAINER_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [[ -z "$API_HOST" ]]; then
        sleep 2
    else
        /usr/bin/kubectl create secret generic ${API_SECRET_NAME} --from-literal=host=${API_HOST}
        exit 0
    fi
done

exit 1

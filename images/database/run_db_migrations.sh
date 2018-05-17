#!/bin/bash
set -x
for i in {1..300}; do
    DB_HOST=$(kubectl get svc ${POSTGRES_CONTAINER_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [[ -z "$MQTT_HOST" ]]; then
        sleep 2
    else
        kubectl create secret generic ${DB_SECRET_NAME} --from-literal=host=${DB_HOST}
        DB_URI="postgresql+psycopg2://$DB_USERNAME:$DB_PASSWORD@$DB_HOST/$DB_NAME"
        subunit2sql-db-manage --database-connection $DB_URI upgrade head
        exit 0
    fi
exit 1

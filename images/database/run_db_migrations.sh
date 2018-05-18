#!/bin/sh

set -x

for i in {1..300}; do
    DB_HOST=$(/usr/bin/kubectl get svc ${POSTGRES_CONTAINER_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [[ -z "$DB_HOST" ]]; then
        sleep 2
    else
        /usr/bin/kubectl create secret generic ${DB_SECRET_NAME} --from-literal=host=${DB_HOST}
        DB_URI="postgresql+psycopg2://$DB_USERNAME:$DB_PASSWORD@$DB_HOST/$DB_NAME"
        /usr/local/bin/subunit2sql-db-manage --database-connection $DB_URI upgrade head
        exit 0
    fi
done

exit 1

#!/bin/sh

DB_URI="postgresql+psycopg2://$DB_USERNAME:$DB_PASSWORD@$DB_HOST/$DB_NAME"
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

echo "db_uri = $DB_URI" >> /etc/openstack-health.conf

/usr/bin/supervisord

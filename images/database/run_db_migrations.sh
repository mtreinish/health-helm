#!/bin/sh

set -x

DB_URI="postgresql+psycopg2://$DB_USERNAME:$DB_PASSWORD@$DB_HOST/$DB_NAME"
/usr/local/bin/subunit2sql-db-manage --database-connection $DB_URI upgrade head

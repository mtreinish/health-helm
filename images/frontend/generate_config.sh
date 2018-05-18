#!/bin/sh

echo "{" > openstack-health/etc/config.json
echo "  \"apiRoot\": \"$API_HOST\"" >> openstack-health/etc/config.json
echo "}" >> openstack-health/etc/config.json

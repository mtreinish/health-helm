#!/bin/sh

echo "{" > /usr/share/nginx/html/config.json
echo "  \"apiRoot\": \"http://$API_HOST\"" >> /usr/share/nginx/html/config.json
echo "}" >> /usr/share/nginx/html/config.json

nginx -g "daemon off;"

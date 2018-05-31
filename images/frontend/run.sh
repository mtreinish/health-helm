#!/bin/sh

echo "{" > /usr/share/nginx/html/config.json
echo "  \"apiRoot\": \"$API_URL\"" >> /usr/share/nginx/html/config.json
echo "}" >> /usr/share/nginx/html/config.json

nginx -g "daemon off;"

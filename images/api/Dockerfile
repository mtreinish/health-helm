FROM python:alpine3.6


RUN apk --no-cache add --virtual build-deps gcc g++
RUN apk --no-cache add musl-dev postgresql-dev linux-headers libxml2-dev
RUN apk --no-cache add nginx supervisor memcached git 

RUN pip3 install -U psycopg2
RUN git clone git://git.openstack.org/openstack/openstack-health
RUN pip3 install -U ./openstack-health

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
&& ln -sf /dev/stderr /var/log/nginx/error.log
# Run nginx in the foreground
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
# Remove default configuration from Nginx
RUN rm -f /etc/nginx/conf.d/default.conf

EXPOSE 80

# Remove default page
RUN rm -f /etc/nginx/sites-enabled/*

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY health-api.conf /etc/nginx/sites-available/health-api.conf
COPY health-uwsgi-api.ini /etc/health-uwsgi-api.ini
COPY openstack-health-api.conf /etc/openstack-health-api.conf

RUN ln -s /etc/nginx/sites-available/health-api.conf /etc/nginx/sites-enabled/health-api.conf
RUN mkdir -p /var/run/uwsgi/

COPY run.sh /root/run.sh

CMD /root/run.sh

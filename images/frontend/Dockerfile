FROM nginx:latest

RUN apt-get update
RUN apt-get install -y git curl build-essential libssl-dev
RUN curl -sLO https://deb.nodesource.com/setup_6.x
RUN bash setup_6.x
RUN apt-get -y install nodejs
RUN npm install -g gulp

RUN git clone git://git.openstack.org/openstack/openstack-health
COPY generate_config.sh .
RUN ./generate_config.sh
RUN cd openstack-health && npm install && gulp prod

RUN cp -r openstack-health/build /usr/share/nginx/html

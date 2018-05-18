FROM nginx:latest

RUN apt-get update
RUN apt-get install -y git curl build-essential libssl-dev rsync
RUN curl -sLO https://deb.nodesource.com/setup_6.x
RUN bash setup_6.x
RUN apt-get -y install nodejs
RUN npm install -g gulp

RUN git clone git://git.openstack.org/openstack/openstack-health
RUN cd openstack-health && npm install && gulp prod
COPY run.sh .

RUN rsync -arPz --delete openstack-health/build/ /usr/share/nginx/html/

CMD ./run.sh

FROM nginx:alpine

ENV DNS_SERVER=1.1.1.1

RUN apk update \
 && apk add jq \
 && rm -rf /var/cache/apk/*

RUN mkdir /config /etc/nginx/templates

COPY entrypoint.sh /entrypoint.sh
COPY templates/* /etc/nginx/templates/

CMD /bin/sh -c "/entrypoint.sh && nginx"

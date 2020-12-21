FROM alpine:3.12 AS build

ENV NGINX_VERSION 1.19.6
ENV NGINX_RTMP_VERSION 1.2.1

WORKDIR /

RUN apk add curl tar
RUN curl https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz > /tmp/nginx.tar.gz
RUN tar -xvf /tmp/nginx.tar.gz
RUN mv /nginx-${NGINX_VERSION} nginx

COPY nginx-rtmp-module /nginx-rtmp-module

WORKDIR /nginx

RUN apk add alpine-sdk pcre-dev openssl-dev zlib-dev
RUN ./configure --add-module=/nginx-rtmp-module
RUN make
RUN make install


FROM alpine:3.12

RUN apk add --no-cache pcre openssl zlib

RUN addgroup -S nginx \
  && adduser -S -D -H -s /sbin/nologin -G nginx -g nginx nginx

COPY --from=build /usr/local/nginx /usr/local/nginx

WORKDIR /usr/local/nginx

COPY nginx.conf ./conf/nginx.conf

EXPOSE 1935/tcp

CMD [ "./sbin/nginx" ]

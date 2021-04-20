FROM ubuntu:20.04 as build

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends wget gnupg build-essential ca-certificates lsb-release

RUN wget -O - https://openresty.org/package/pubkey.gpg | apt-key add - && \
    echo "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" > openresty.list && \
    mv openresty.list /etc/apt/sources.list.d/

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends lua5.1 liblua5.1-dev libssl-dev openresty m4 zip unzip

RUN wget https://luarocks.org/releases/luarocks-3.7.0.tar.gz && \
    tar zxpf luarocks-3.7.0.tar.gz && \
    cd luarocks-3.7.0 && \
    ./configure && make && make install

RUN luarocks install lapis && luarocks install lua-requests && luarocks install bit32 && luarocks install lua-cjson 2.1.0-1

WORKDIR /app
COPY . .
RUN mkdir logs

EXPOSE 8080
ENTRYPOINT ["/usr/local/openresty/nginx/sbin/nginx", "-p", "/app", "-c", "nginx.conf"]

STOPSIGNAL SIGQUIT
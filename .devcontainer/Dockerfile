# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.166.1/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version: bionic, focal
ARG VARIANT="focal"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

RUN wget -O - https://openresty.org/package/pubkey.gpg | sudo apt-key add - && \
    echo "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" > openresty.list && \
    mv openresty.list /etc/apt/sources.list.d/

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends lua5.1 liblua5.1-dev build-essential openresty m4

RUN wget https://luarocks.org/releases/luarocks-3.7.0.tar.gz && \
    tar zxpf luarocks-3.7.0.tar.gz && \
    cd luarocks-3.7.0 && \
    ./configure && make && make install

RUN luarocks install lapis && luarocks install lua-requests && luarocks install bit32 && luarocks install lua-cjson 2.1.0-1
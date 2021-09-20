# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.148.1/containers/debian/.devcontainer/base.Dockerfile

# [Choice] Debian version: buster, stretch
ARG VARIANT="buster"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends xz-utils curl wget vim unzip

RUN curl -L https://nodejs.org/dist/v14.15.1/node-v14.15.1-linux-x64.tar.xz -o /tmp/node.tar.xz \
    && tar -xf /tmp/node.tar.xz -C /usr/local/bin 

ENV PATH="/usr/local/bin/node-v14.15.1-linux-x64/bin:${PATH}"

# set up a new folder for npm to install globally on a dev container without root access
# https://stackoverflow.com/questions/46058546/error-eacces-permission-denied-access-usr-lib-node-modules/49122289

RUN npm install -g truffle --unsafe-perm

RUN npm install -g ganache-cli --unsafe-perm
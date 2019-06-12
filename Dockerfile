FROM phusion/baseimage:0.9.22
MAINTAINER honigbrand

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US
ENV LC_ALL en_US.UTF-8
ENV EDITOR vim
ENV TERM xterm

RUN locale-gen en_US.UTF-8

RUN sed -i -e 's,http://archive.ubuntu.com,http://de.archive.ubuntu.com,g' /etc/apt/sources.list
RUN apt-get update && \
	apt-get -y install git wget curl jq tzdata && \
	apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# Deactivate unused services
RUN mv /etc/service/cron /etc/service/.cron
RUN mv /etc/service/sshd /etc/service/.sshd
RUN mv /etc/service/syslog-ng /etc/service/.syslog-ng
RUN mv /etc/service/syslog-forwarder /etc/service/.syslog-forwarder
RUN chmod 444 /etc/my_init.d/00_regen_ssh_host_keys.sh

RUN apt-get update && \
	apt-get install -y python build-essential libfreetype6 libfontconfig1 && \
	apt-get clean

ENV NODE_VERSION=8.12.0

RUN curl --retry 3 -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
    && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
    && rm "node-v$NODE_VERSION-linux-x64.tar.gz" \
    && npm install --progress=false -g npm \
    && npm cache clear --force

# Karma runs JS tests through PhantomJS
RUN cd /tmp && \
	wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
	tar xjf phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
	cp phantomjs*/bin/phantomjs /usr/local/bin && \
	rm -rf phantomjs*

WORKDIR /app

RUN mkdir /root/.npm-packages && \
	echo 'prefix=${HOME}/.npm-packages' > /root/.npmrc && \
	echo 'NPM_PACKAGES="${HOME}/.npm-packages"' >> /root/.bashrc && \
	echo 'NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"' >> /root/.bashrc && \
	echo 'PATH="$NPM_PACKAGES/bin:$(npm bin):$PATH"' >> /root/.bashrc && \
	echo 'export NPM_PACKAGES' >> /root/.bashrc && \
	echo 'export NODE_PATH' >> /root/.bashrc

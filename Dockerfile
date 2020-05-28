FROM golang:latest AS backend-build

WORKDIR /go/src/app
COPY ./backend .

ENV GO111MODULE on
ENV GOPROXY https://mirrors.aliyun.com/goproxy/

RUN go install -v ./...

FROM node:8.16.0-alpine AS frontend-build

ADD ./frontend /app
WORKDIR /app

# install frontend
RUN npm config set unsafe-perm true
RUN npm install -g yarn \
	&& yarn install --registry=https://registry.npm.taobao.org

RUN npm run build:prod

# images
FROM centos:centos7

# set as non-interactive
ENV DEBIAN_FRONTEND noninteractive

# set CRAWLAB_IS_DOCKER
ENV CRAWLAB_IS_DOCKER Y

ENV container=docker

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*; \
rm -f /etc/systemd/system/*.wants/*; \
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*; \
rm -f /lib/systemd/system/anaconda.target.wants/*;

# install packages
RUN chmod 777 /tmp \
	&& yum makecache \
	&& yum install -y epel-release \
	&& yum install -y curl git net-tools iputils-ping ntp ntpdate python3 python3-pip wget \
	&& yum install -y nginx \
	&& yum install -y initscripts \
	&& yum clean all \
	&& ln -s /usr/bin/pip3 /usr/local/bin/pip \
	&& ln -s /usr/bin/python3 /usr/local/bin/python

# install dumb-init
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64
RUN chmod +x /usr/local/bin/dumb-init

# install backend
RUN pip install scrapy pymongo bs4 requests crawlab-sdk scrapy-splash

# add files
ADD . /app

# copy backend files
RUN mkdir -p /opt/bin
COPY --from=backend-build /go/bin/crawlab /opt/bin
RUN cp /opt/bin/crawlab /usr/local/bin/crawlab-server

# copy frontend files
COPY --from=frontend-build /app/dist /app/dist

# copy nginx config files
COPY ./nginx/crawlab.conf /etc/nginx/conf.d
#RUN /app/docker_init.sh
RUN systemctl enable nginx.service

# working directory
WORKDIR /app/backend

#RUN /app/docker_init.sh

VOLUME /run /tmp
VOLUME [ "/sys/fs/cgroup" ]

# timezone environment
ENV TZ Asia/Shanghai

# language environment
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# frontend port
EXPOSE 8080

# backend port
EXPOSE 8000

# start backend
CMD ["/bin/bash", "/app/docker_init.sh"]
#CMD ["/usr/sbin/init"]

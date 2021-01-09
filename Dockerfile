FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

COPY file/etc/apt/sources.list /etc/apt/sources.list

RUN apt-get update

RUN apt-get install -y locales
RUN locale-gen "en_US.UTF-8"

ENV TZ Asia/Shanghai
ENV LANG en_US.UTF-8

RUN apt-get -y upgrade

####################
# 初始化
####################
RUN apt-get install -y mlocate openssh-server iproute2 curl wget tcpdump vim telnet screen sudo rsync tcpdump openssh-client tar bzip2 xz-utils pwgen
RUN echo set fencs=utf-8,gbk >> /etc/vim/vimrc

####################
# 配置SSH服务
####################
RUN mkdir /var/run/sshd

RUN mkdir /root/.ssh
RUN touch /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

RUN echo "*               soft   nofile            65535" >> /etc/security/limits.conf
RUN echo "*               hard   nofile            65535" >> /etc/security/limits.conf
RUN sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config
RUN sed -i "s/#GSSAPICleanupCredentials yes/GSSAPICleanupCredentials no/" /etc/ssh/sshd_config
RUN sed -i "s/#MaxAuthTries 6/MaxAuthTries 10/" /etc/ssh/sshd_config
RUN sed -i "s/#ClientAliveInterval 0/ClientAliveInterval 30/" /etc/ssh/sshd_config
RUN sed -i "s/#ClientAliveCountMax 3/ClientAliveCountMax 10/" /etc/ssh/sshd_config

####################
# 安装PHP
####################
RUN apt-get install -y \
    php \
    php-bcmath \
    php-bz2 \
    php-cli \
    php-common \
    php-curl \
    php-fpm \
    php-gd \
    php-intl \
    php-json \
    php-mbstring \
    php-mysql \
    php-opcache \
    php-pdo \
    php-pear \
    php-gettext \
    php-phpseclib \
    php-readline \
    php-tcpdf \
    php-xml \
    php-xmlrpc \
    php-zip
RUN touch /var/log/fpm-php.www.log /var/log/php7.2-fpm.log
RUN chown www-data:www-data /var/log/fpm-php.www.log /var/log/php7.2-fpm.log

####################
# 安装MySQL
####################
RUN apt-get install -y mysql-server mysql-client mysql-common

# 设置配置文件
RUN sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf
RUN sed -i 's/max_allowed_packet	= 16M/max_allowed_packet	= 200M/' /etc/mysql/conf.d/mysqldump.cnf

####################
# 安装Nginx
####################
RUN apt-get install -y nginx-full
COPY file/etc/nginx/nginx.conf /etc/nginx/nginx.conf

# 配置PHP-FPM默认站点
COPY file/etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
RUN mkdir -p /data/web/default
RUN echo '<?php phpinfo(); ?>' > /data/web/default/index.php
RUN chown -R www-data:www-data /data/web/default

####################
# 清理
####################
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

####################
# 设置开机启动
####################
COPY file/usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

WORKDIR /root

EXPOSE 80 3306

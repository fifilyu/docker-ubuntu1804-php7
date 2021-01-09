# docker-ubuntu1804-php7

基于Ubuntu 18.04 + PHP7的Docker镜像。

## 0. 构建镜像

### 克隆Dockerfile项目

#### 方法一（国内）

    git clone https://gitee.com/fifilyu/docker-ubuntu1804-php7.git

#### 方法二（全球）

    git clone https://github.com/fifilyu/docker-ubuntu1804-php7.git

### 构建镜像

    cd docker-ubuntu1804-php7
    sudo docker build -t fifilyu/docker-ubuntu1804-php7:latest .

## 1. 环境组件列表

1. PHP-7.2（PHP-FPM）
2. Nginx 1.14
3. MySQL 5.7.32

## 2. 开发相关

### 2.1 开放端口

容器内的服务，默认监听 `0.0.0.0`：

* SSH->22
* Nginx->80
* MySQL->3306

MySQL的客户端工具可以连接容器内的服务端口，这样可以直接导入、导出、管理数据。

也能通过SSH+私钥方式连接容器的22端口，方便查看日志等等。

### 2.2 使用Hosting数据目录启动一个容器

    docker run -d \
        --env LANG=en_US.UTF-8 \
	    --env TZ=Asia/Shanghai \
        -e MYSQL_ROOT_PASSWORD=mypassword \
        -v /some/content:/data/web/default:ro \
        --name some-ubuntu1804-php7 fifilyu/docker-ubuntu1804-php7:latest

将本地目录 `/some/content` 挂载到容器的 `/data/web/default` 目录。

本地用 Visual Studio Code 打开目录 `/some/content`，作为写PHP代码的工作空间。

挂载后，更新本地PHP代码，访问 http://容器IP 可以直接看到效果，不用再上传。

### 2.3 自定义设置

自定义配置参数，可以直接通过Docker命令进入bash编辑：

    docker exec -it 容器名称 bash

或者通过SSH+私钥方式连接容器的22端口：

    ssh 容器IP

## 3. 使用方法

### 3.1 启动一个容器很简单

    docker run -d \
        --env LANG=en_US.UTF-8 \
	    --env TZ=Asia/Shanghai \
        -e MYSQL_ROOT_PASSWORD=mypassword \
        --name some-ubuntu1804-php7 fifilyu/docker-ubuntu1804-php7:latest

此时访问 http://容器IP 能看到 PHP 版本信息。

另外，必须指定 `MYSQL_ROOT_PASSWORD` 参数，用于设置MySQL的root用户密码。

### 3.2 启动带公钥的容器

    docker run -d \
        --env LANG=en_US.UTF-8 \
	    --env TZ=Asia/Shanghai \
        -e MYSQL_ROOT_PASSWORD=mypassword \
        -e PUBLIC_STR="$(<~/.ssh/root@fifilyu.pub)" \
        --name some-ubuntu1804-php7 fifilyu/docker-ubuntu1804-php7:latest

效果同上。另外，可以通过SSH无密码登录容器。

`$(<~/.ssh/root@fifilyu.pub)` 表示在命令行读取文件内容到变量。

`PUBLIC_STR="$(<~/.ssh/root@fifilyu.pub)"` 也可以写作：

    PUBLIC_STR="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLGJVJI1Cqr59VH1NVQgPs08n7e/HRc2Q8AUpOWGoJpVzIgjO+ipjqwnxh3eiBd806eXIIa5OFwRm0fYfMFxBOdo3l5qGtBe82PwTotdtpcacP5Dkrn+HZ1kG+cf0BNSF5oXbTCTrqY12/T8h4035BXyRw7+MuVPiCUhydYs3RgsODA47ZR3owgjvPsayUd5MrD8gidGqv1zdyW9nQXnXB7m9Sn9Mg8rk6qBxQUbtMN9ez0BFrUGhXCkW562zhJjP5j4RLVfvL2N1bWT9EoFTCjk55pv58j+PTNEGUmu8PrU8mtgf6zQO871whTD8/H6brzaMwuB5Rd5OYkVir0BXj fifilyu@archlinux"

### 3.3 启动容器时暴露端口

    docker run -d \
        --env LANG=en_US.UTF-8 \
	    --env TZ=Asia/Shanghai \
        -e MYSQL_ROOT_PASSWORD=mypassword \
        -p 8080:80 \
        --name some-ubuntu1804-php7 fifilyu/docker-ubuntu1804-php7:latest

此时访问 http://localhost:8080 能看到 PHP 版本信息。

更复杂的容器端口映射：

    docker run -d \
        --env LANG=en_US.UTF-8 \
	    --env TZ=Asia/Shanghai \
        -e MYSQL_ROOT_PASSWORD=mypassword \
        -p 8022:22 \
        -p 8080:80 \
        -p 8330:3306 \
        --name some-ubuntu1804-php7 fifilyu/docker-ubuntu1804-php7:latest

## 4. 环境配置

### 4.1 配置文件

#### 4.1.1 PHP

PHP主配置文件:

    /etc/php/7.2/fpm/php.ini

PHP模块配置文件:

    /etc/php/7.2/fpm/conf.d/

[NOTE]
如果要启用或禁用模块，请直接修改 `php.d` 下的 `.ini` 文件。

PHP-FPM配置文件:

    /etc/php/7.2/fpm/php-fpm.conf

#### 4.1.2 Nginx

Nginx主配置文件:

    /etc/nginx/nginx.conf

Nginx Host配置文件:

    /etc/nginx/conf.d

`/etc/nginx/conf.d/default.conf` 是默认创建的 Host ，监听 `80` 端口。

Web目录:

    /data/web

`/data/web/default` 目录是默认站点的文件目录。

#### 4.1.3 MySQL

MySQL主配置文件: 

    /etc/mysql/mysql.conf.d/mysqld.cnf

### 4.2 运行目录

#### 4.2.1 PHP

日志文件:

    /var/log/php7.2-fpm.log
    /var/log/fpm-php.www.log

#### 4.2.2 Nginx

日志目录:

    /var/log/nginx

#### 4.2.3 MySQL

日志目录:

    /var/log/mysql

数据目录:

    /var/lib/mysql

### 4.3 模块

#### 4.3.1 默认启用

* bcmath
* bz2
* calendar
* ctype
* curl
* dom
* exif
* fileinfo
* ftp
* gd
* gettext
* iconv
* intl
* json
* mbstring
* mysqli
* mysqlnd
* opcache
* pdo
* pdo_mysql
* phar
* posix
* readline
* shmop
* simplexml
* sockets
* sysvmsg
* sysvsem
* sysvshm
* tokenizer
* wddx
* xml
* xmlreader
* xmlrpc
* xmlwriter
* xsl
* zip
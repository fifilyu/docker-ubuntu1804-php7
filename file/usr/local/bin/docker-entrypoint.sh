#!/bin/sh
service ssh start

rm -f /var/run/mysqld/mysqld.pid /var/run/mysqld/mysqld.sock /var/run/mysqld/mysqld.sock.lock
chown -R mysql:mysql /var/lib/mysql /var/log/mysql
service mysql start

rm -f /run/php/php7.2-fpm.pid
service php7.2-fpm start

rm -f /var/run/nginx.pid
service nginx start

sleep 1

auth_lock_file=/var/log/docker_init_auth.lock

if [ ! -z "${PUBLIC_STR}" ]; then
    if [ -f ${auth_lock_file} ]; then
        echo "`date "+%Y-%m-%d %H:%M:%S"` [信息] 跳过添加公钥"
    else
        echo "${PUBLIC_STR}" >> /root/.ssh/authorized_keys

        if [ $? -eq 0 ]; then
            echo "`date "+%Y-%m-%d %H:%M:%S"` [信息] 公钥添加成功"
            echo `date "+%Y-%m-%d %H:%M:%S"` > ${auth_lock_file}
        else
            echo "`date "+%Y-%m-%d %H:%M:%S"` [错误] 公钥添加失败"
            exit 1
        fi
    fi
fi

pw=$(pwgen -1 20)
echo "$(date +"%Y-%m-%d %H:%M:%S") [信息] Root用户密码：${pw}"
echo "root:${pw}" | chpasswd

mysql_lock_file=/var/log/docker_init_mysql.lock

if [ -z "${MYSQL_ROOT_PASSWORD}" ]; then
    echo "`date "+%Y-%m-%d %H:%M:%S"` [错误] 必须指定MySQL新密码"
    exit 1
else
    if [ -f ${mysql_lock_file} ]; then
        echo "`date "+%Y-%m-%d %H:%M:%S"` [信息] 跳过修改MySQL密码"
    else
        echo "`date "+%Y-%m-%d %H:%M:%S"` [信息] MySQL新密码："${MYSQL_ROOT_PASSWORD}

        mysql -e "update mysql.user set plugin='mysql_native_password';"
        mysql -e "flush privileges;"
        mysql -e "alter user 'root'@'localhost' identified by '${MYSQL_ROOT_PASSWORD}';"

        if [ $? -eq 0 ]; then
            echo "`date "+%Y-%m-%d %H:%M:%S"` [信息] MySQL密码修改成功"
        else
            echo "`date "+%Y-%m-%d %H:%M:%S"` [错误] MySQL密码修改失败"
            exit 1
        fi

        mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e \
            "CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;" 2>/dev/null

        if [ $? -eq 0 ]; then
            echo "`date "+%Y-%m-%d %H:%M:%S"` [信息] 设置MySQL远程登录成功"
        else
            echo "`date "+%Y-%m-%d %H:%M:%S"` [错误] 设置MySQL远程登录失败"
            exit 1
        fi

        # 密码和远程登录设置成功后锁定
        echo `date "+%Y-%m-%d %H:%M:%S"` > ${mysql_lock_file}
    fi
fi

# 保持前台运行，不退出
while true
do
    sleep 3600
done


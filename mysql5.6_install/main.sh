#!/bin/bash
#install mysql 5.6
#tommy
#$1=password,if you don't input $1 ,password default is '123456'

. ./check.sh

check_root
check_internet
init_yum


MYSQL_BIN_SOURCE="mysql-5.6.37-linux-glibc2.12-x86_64"
MYSQL_DOWN_URL=http://ozi3kq0eb.bkt.clouddn.com/${MYSQL_BIN_SOURCE}.tar.gz

PWD="$(pwd)"
if [ $# -ne 0 ];then
	MYSQL_PASSWORD=$1
else
	MYSQL_PASSWORD="123456"
fi
sleep 1
if [ -f $lock_dir/mysql ];then
		echo "该脚本已经锁住，原因之前已经安装，如果确认没有安装，请删除$lock_dir/rabbitmq"
		exit 10
else
	yum install -y numactl-devel wget 
	useradd -s /sbin/nologin mysql
	cd ./source/&&wget ${MYSQL_DOWN_URL}&&tar -xf ${MYSQL_BIN_SOURCE}.tar.gz -C /usr/local
	ln -s /usr/local/${MYSQL_BIN_SOURCE} /usr/local/mysql
	chown -R mysql.mysql /usr/local/mysql/data
	/usr/local/mysql/scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data/ --user=mysql
	cp -a /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld 
	mv /etc/my.cnf{,.bak}

	\cp -f ${PWD}/my.cnf /etc/my.cnf
	/etc/init.d/mysqld start

	echo 'export PATH=$PATH:/usr/local/mysql/bin'>>/etc/profile&&source /etc/profile

	mysql -e "USE mysql;DELETE FROM user where user='';update user set password=password(\"${MYSQL_PASSWORD}\");flush privileges;"&&touch $lock_dir/mysql
	netstat -tlunp|grep mysqld
	echo "your mysql password : ${MYSQL_PASSWORD}"
	
fi

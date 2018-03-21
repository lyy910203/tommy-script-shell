#!/bin/bash
#install nginx 

. ./check.sh


check_root
check_internet
init_yum

redis_version=4.0.8
redis_url=http://download.redis.io/releases/redis-$redis_version.tar.gz

case $system_version in
	6)
			wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo>/dev/null;;
			#yum clean all
			#yum makecache ;;
	7)
			wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo>/dev/null;;
			#yum clean all
			#yum makecache ;;
	*)
		echo "your system is not run this shell"
esac

function install_redis(){
	if [ -f $lock_dir/redis ];then
		echo "该脚本已经锁住，原因之前已经安装，如果确认没有安装，请删除$lock_dir/redis"
		exit 10
	else
		cd /usr/local/src
		wget $redis_url &&tar -xf redis-$redis_version.tar.gz
		check_ok
		\cp -pr  redis-$redis_version /usr/local/redis-$redis_version && cd /usr/local/
		ln -s redis-$redis_version redis&&cd redis
		make
		check_ok
		echo "vm.overcommit_memory = 1">>/etc/sysctl.conf &&sysctl -p
		echo 'echo 511 > /proc/sys/net/core/somaxconn' >>/etc/rc.local
		echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >>/etc/rc.local
		echo 511 > /proc/sys/net/core/somaxconn
		echo never > /sys/kernel/mm/transparent_hugepage/enabled
		sed -i 's#daemonize no#daemonize yes#g' /usr/local/redis/redis.conf
		/usr/local/redis/src/redis-server /usr/local/redis/redis.conf
		echo '/usr/local/redis/src/redis-server /usr/local/redis/redis.conf'>>/etc/rc.local
		echo > $lock_dir/redis
		echo 'export PATH=$PATH:/usr/local/redis/src'>>/etc/profile
		. /etc/profile
	fi
}
install_redis	


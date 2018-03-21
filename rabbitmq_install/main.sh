#!/bin/bash
#install rabbitmq   centos 6 7
#tommy lin
#已知问题，如果HOSTS包含了IP对应主机名，安装无法启动
. ./check.sh

check_root
check_internet
init_yum

rabbitmq_user=admin
rabbitmq_pass=adminpasspord
rabbitmq_down_url=https://github.com/rabbitmq/rabbitmq-server/releases/download/rabbitmq_v3_6_15
rabbitmq_centos6_name=rabbitmq-server-3.6.15-1.el6.noarch.rpm
rabbitmq_centos7_name=rabbitmq-server-3.6.15-1.el7.noarch.rpm
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

function install_rabbitmq(){
	if [ -f $lock_dir/rabbitmq ];then
		echo "该脚本已经锁住，原因之前已经安装，如果确认没有安装，请删除$lock_dir/rabbitmq"
		exit 10
	else
		cd /usr/local/src
		#erlang install 废弃yum
		#wget https://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm
		#rpm -Uvh erlang-solutions-1.0-1.noarch.rpm
		#yum install -y erlang
		yum install -y openssl_devel mesa-libGLU-devel wxGTK-devel unixODBC #erlang需要
		yum install -y socat  #rabbitmq需要

		if [ "$system_version" == "6" ];then
			wget http://ozi3kq0eb.bkt.clouddn.com/esl-erlang_20.3-1~centos~6_amd64.rpm&&rpm -ivh esl-erlang_20.3-1~centos~6_amd64.rpm
			wget $rabbitmq_down_url/$rabbitmq_centos6_name && rpm -ivh $rabbitmq_centos6_name --nodeps
			\cp /usr/share/doc/rabbitmq-server-3.6.15/rabbitmq.config.example /etc/rabbitmq/rabbitmq.config
			service rabbitmq-server start
		elif [ "$system_version" == "7" ];then
			wget http://ozi3kq0eb.bkt.clouddn.com/esl-erlang_20.3-1~centos~7_amd64.rpm&&rpm -ivh esl-erlang_20.3-1~centos~7_amd64.rpm
			wget $rabbitmq_down_url/$rabbitmq_centos7_name && rpm -ivh $rabbitmq_centos7_name --nodeps
			\cp /usr/share/doc/rabbitmq-server-3.6.15/rabbitmq.config.example /etc/rabbitmq/rabbitmq.config
			systemctl start rabbitmq-server
			systemctl enable rabbitmq-server
		fi
		rabbitmqctl add_user $rabbitmq_user $rabbitmq_pass #add admin user
		rabbitmqctl set_user_tags ${rabbitmq_user} administrator  #add user in administrators
		rabbitmqctl  set_permissions -p /  ${rabbitmq_user} '.*' '.*' '.*'  #赋予权限
		rabbitmq-plugins enable rabbitmq_management #开启web管理界面
		
		touch $lock_dir/rabbitmq
	fi
}
install_rabbitmq

		


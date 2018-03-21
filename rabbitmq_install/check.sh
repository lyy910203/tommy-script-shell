#!/bin/bash
#检测系统
nginx_url='http://nginx.org/download/nginx-1.12.2.tar.gz'
nginx_version='1.12.2'
scprict_dir=`pwd`
#检测是否超级管理员
function check_root() {
    if [[ `id -u` -ne 0 ]];then
        echo "you is not super user,plese su - root"
        exit 1
    fi
	echo "检查登录管理员                   通过"
}
#检测是否连接网络
function check_internet(){
    ping -c 1 -w 1 www.baidu.com>/dev/null
    if [ $? -ne 0 ];then
        echo "your internet is not link"
    fi
	echo "检查网络                         通过"
}
#返回centos系统版本6 or 7 才支持
system_version=`grep -Eo "[0-9]\.[0-9]" /etc/redhat-release |cut -d'.' -f1`
#在系统第一次需要yum安装一些必要的包
function init_yum(){
	echo "初始化，安装环境包gcc gcc-c++ gd gd-devel openssl-devel unzip lrzsz wget"&&sleep 3
	yum install -y gcc gcc-c++ gd gd-devel openssl-devel unzip lrzsz wget vim net-tools pcre-devel
	id www>/dev/null
	if [ $? -ne 0 ];then
	    useradd -s /sbin/nologin www
	fi
}

function check_ok(){
	#检查是否正常
	if [ $? -ne 0 ];then
		echo "错误 错误  错误"
		exit 100
	fi
}

cpu_core=`grep processor /proc/cpuinfo|wc -l`

#lock dir
lock_dir=/etc/tommy
if [ ! -d $lock_dir ];then
	echo "锁目录不存在，创建中。。"
	mkdir -pv $lock_dir
fi

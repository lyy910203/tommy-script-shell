#!/bin/bash
#install nginx 

. ./check.sh


check_root
check_internet
init_yum
apache7_version=7.0.73
jdk1_7_version=1.7.0_79
apache7_url=http://ozi3kq0eb.bkt.clouddn.com/apache-tomcat-$apache7_version.tar.gz
jdk1_7_url=http://ozi3kq0eb.bkt.clouddn.com/jdk$jdk1_7_version.tar.gz

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

function install_tomcat(){
	if [ -f $lock_dir/tomcat ];then
		echo "该脚本已经锁住，原因之前已经安装，如果确认没有安装，请删除$lock_dir/tomcat"
		exit 10
	else
		echo "install tomcat 7.$apache7_version"

		cd /usr/local/src
		wget $jdk1_7_url &&wget $apache7_url
		tar -xf jdk$jdk1_7_version.tar.gz && mv jdk$jdk1_7_version /usr/local/jdk
		echo 'JAVA_HOME=/usr/local/jdk'>>/etc/profile
		echo 'export JAVA_HOME' >>/etc/profile
		echo 'export PATH=$JAVA_HOME/bin:$PATH' >>/etc/profile
		echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >>/etc/profile
		. /etc/profile 
		java -version
		cd /usr/local/src
		tar -xf apache-tomcat-$apache7_version.tar.gz && mv apache-tomcat-$apache7_version /usr/local/
		ln -s  /usr/local/apache-tomcat-$apache7_version /usr/local/apache-tomcat
		mv /usr/local/apache-tomcat/conf/server.xml /usr/local/apache-tomcat/conf/server.xml.default &&cp $scprict_dir/conf/server.xml /usr/local/apache-tomcat/conf/server.xml
		/usr/local/apache-tomcat/bin/catalina.sh start
		echo > $lock_dir/tomcat
		netstat -tlunp|grep java
	fi
}
install_tomcat

		


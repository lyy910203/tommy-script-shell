#!/bin/bash
#install nginx 

. ./check.sh


check_root
check_internet
init_yum
apache8_version=8.5.12
jdk1_8_version=8u112

apache8_url=http://ozi3kq0eb.bkt.clouddn.com/apache-tomcat-$apache8_version.tar.gz
jdk1_8_url=http://ozi3kq0eb.bkt.clouddn.com/jdk-$jdk1_8_version-linux-x64.tar.gz

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
		echo "install tomcat 8.$apache8_version"

		cd /usr/local/src
		wget $apache8_url &&wget $jdk1_8_url
		tar -xf jdk-8u112-linux-x64.tar.gz && mv jdk1.8.0_112 /usr/local/jdk
		echo 'JAVA_HOME=/usr/local/jdk'>>/etc/profile
		echo 'export JAVA_HOME' >>/etc/profile
		echo 'export PATH=$JAVA_HOME/bin:$PATH' >>/etc/profile
		echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >>/etc/profile
		. /etc/profile 
		java -version
		cd /usr/local/src
		tar -xf apache-tomcat-$apache8_version.tar.gz && mv apache-tomcat-$apache8_version /usr/local/
		cd /usr/local/&&ln -s apache-tomcat-$apache8_version apache-tomcat
		sed -i '2i JAVA_HOME=/usr/local/jdk' /usr/local/apache-tomcat/bin/catalina.sh
		sed -i '3i export JAVA_HOME' /usr/local/apache-tomcat/bin/catalina.sh
		sed -i '4i export PATH=$JAVA_HOME/bin:$PATH' /usr/local/apache-tomcat/bin/catalina.sh
		sed -i '5i export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' /usr/local/apache-tomcat/bin/catalina.sh
		/usr/local/apache-tomcat/bin/catalina.sh start
		echo > $lock_dir/tomcat
		netstat -tlunp|grep java
	fi
}
install_tomcat

		


#!/bin/bash
#install nginx 

. ./check.sh

check_root
check_internet
init_yum
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
function install_nginx(){
	if [ -f ${lock_dir}/nginx ];then
		echo "该脚本已经锁住，原因之前已经安装，如果确认没有安装，请删除$lock_dir/nginx"
		exit 10
	else
		cd /usr/local/src
		wget $nginx_url&&tar -xf nginx-$nginx_version.tar.gz&&cd nginx-$nginx_version
		check_ok
		./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-pcre --with-http_realip_module --with-http_image_filter_module
		check_ok
		make -j$cpu_core&& make install&&mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.default &&cp $scprict_dir/conf/nginx.conf /usr/local/nginx/conf/
		check_ok
		/usr/local/nginx/sbin/nginx
		check_ok
		echo "install OK"
		echo > $lock_dir/nginx
		echo '/usr/local/nginx/sbin/nginx' >>/etc/rc.local
		netstat -tlunp|grep nginx
	fi
}
install_nginx

		


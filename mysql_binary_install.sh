#!/bin/bash
#__Author__:Allen_Jol at 2018-03-21 13:52:13
#Description: install mysql-5.x binary for centos 6.x

CPUINFO=`cat /proc/cpuinfo | grep -c  processor`
DIR="/usr/local/src"
MDIR="/usr/local/mysql"
DATADIR="$MDIR/data"
MYSQL56_BIN_SOURCE="mysql-5.6.39-linux-glibc2.12-x86_64"
MYSQL56_DOWN_URL="https://cdn.mysql.com//Downloads/MySQL-5.6/${MYSQL56_BIN_SOURCE}.tar.gz"
MYSQL57_BIN_SOURCE="mysql-5.7.21-linux-glibc2.12-x86_64"
MYSQL57_DOWN_URL="https://cdn.mysql.com//Downloads/MySQL-5.7/${MYSQL57_BIN_SOURCE}.tar.gz"

#cpuinfo=${grep "processor" /proc/cpuinfo | wc -l}
function  checkroot(){
if [ $UID -ne  0 ];then
	echo -e "\e[1;35mPlease login as root\e[0m"
	exit 1
fi
} 
function create_user_mysql(){
	gflag=`cat  /etc/group  |awk -F':'  '{print  $1}'  | grep  mysql`
	[[ $gflag != "" ]]  && echo -e "\e[1;35mgroup 'mysql' already exists\e[0m"  || groupadd mysql
	uflag=`cat  /etc/passwd  |awk -F':'  '{print  $1}'  | grep  mysql`
	[[ $uflag != ""  ]] && echo -e "\e[1;35muser 'mysql' already exists\e[0m" || useradd -r mysql -g mysql -s /sbin/nologin
}
function  Msgbox(){
if [  $? -ne 0 ];then
	echo -e "\e[1;35mError,please check\e[0m"
	exit 1
fi
}
function  install_required_packages(){
	echo -e "Install  required  packages,please  wait...\t Or you can press \e[5;35m[ctrl+c]\e[0m to exit."
	yum -y install wget gcc-c++ numactl autoconf automake libaio-devel zlib zlib-devel ncurses ncurses-devel  tcp_wrappers-devel bison-devel bison build-essential libncurses5-dev cmake openssl  openssl-devel >/dev/null
}
function  check_datadir(){
	[ -f "${MDIR}" ] && echo -e "\e[1;35m目录被锁定，请确保没有安装过mysql服务\e[0m" && exit 1
	[ ! -d "$MDIR" ] && mkdir  -p $MDIR
	#[ ! -d "$MDIR/data" ] && mkdir -p "$MDIR/data"  二进制的mysql解压出来就有一个data目录的
	chown  -R mysql.mysql   $MDIR
}
function menu(){
	echo -e "\e[1;34m**************************************************************\e[0m"
cat<<EOF
Please choose  mysql  version  which  you want to install: 
  1:mysql-binary-5.6.39
  2:mysql-binary-5.7.21
EOF
	echo -e "\e[1;34m**************************************************************\e[0m"
}
function  mysql_version(){
	read -p  "please choose mysql  version that you  want to install:" flag
	read -p  "please enter mysql root password that you want to set:" mysql_password
}
 
function  mysql_download(){
case $flag  in
1)
	VERSION="mysql-5.6.39"
	echo -e "\e[1;34m${VERSION} binary will be installed\e[0m"
	[ -f "${DIR}/${MYSQL56_BIN_SOURCE}.tar.gz" ] && cd ${DIR} && rm -f "${DIR}/${MYSQL56_BIN_SOURCE}.tar.gz"
	[ -f "${DIR}/${MYSQL56_BIN_SOURCE}/" ] && cd ${DIR} && rm -f "${DIR}/${MYSQL56_BIN_SOURCE}/"
	[ ! -f "${DIR}/${MYSQL56_BIN_SOURCE}.tar.gz" ] && cd ${DIR}
    NETTEST=`ping -c 1 www.baidu.com >>/dev/null`
    if [ $? -eq 0 ];then
    	echo -e "\e[1;34mDownload ${VERSION} now,please wait...\e[0m"
    	wget -c ${MYSQL56_DOWN_URL}
    else
    	echo -e "\e[1;35mnetwork is error,please check first.\e[0m"
    	exit 1
    fi
;;
2)
  VERSION="mysql-5.7.21"
  echo -e "\e[1;34m${VERSION} binary will be installed.\e[0m"
  [ -f "${DIR}/${MYSQL57_BIN_SOURCE}.tar.gz" ] && cd ${DIR} && rm -f "${DIR}/${MYSQL57_BIN_SOURCE}.tar.gz"
  [ -f "${DIR}/${MYSQL57_BIN_SOURCE}/" ] && cd ${DIR} && rm -f "${DIR}/${MYSQL57_BIN_SOURCE}/"
  [ ! -f "${DIR}/${MYSQL57_BIN_SOURCE}.tar.gz" ] && cd ${DIR}
  NETTEST=`ping -c 1 www.baidu.com >>/dev/null`
  if [ $? -eq 0 ];then
  	echo -e "\e[1;34mDownload ${VERSION} now,please wait...\e[0m"
  	wget -c ${MYSQL57_DOWN_URL}
  else
   	echo -e "\e[1;35mnetwork is error,please check first.\e[0m"
   	exit 1
  fi
;;
*)
  echo -e "\e[1;35mPlease  input number 1 or 2,other is not valid\e[0m"
  mysql_version
  mysql_download
esac
}

function mysql_install(){
case  $VERSION  in
"mysql-5.6.39")
echo -e "\e[1;34mConfig mysql,please wait...\e[0m"
cd ${DIR} && tar zxf ${MYSQL56_BIN_SOURCE}.tar.gz && cd ${MYSQL56_BIN_SOURCE}/ && \mv ./* /usr/local/mysql
mkdir -p /usr/local/mysql/logs && chown -R mysql.mysql /usr/local/mysql
[ $? -eq 0 ] && echo  "Mysql install ok ,The next step is init mysql." || echo  -e "\e[1;35mMysql install error ,please check\e[0m"
[ -f "/etc/my.cnf" ] && \mv /etc/my.cnf /etc/my.cnf.bak
cat >/etc/my.cnf<<EOF
[client]
#password   = your_password
port        = 3306
socket      = /tmp/mysql.sock

# The MySQL server
[mysqld]
# Basic
relay_log_purge = 0
user = mysql
basedir = /usr/local/mysql
datadir = /usr/local/mysql/data
tmpdir  = /usr/local/mysql
log-bin = /usr/local/mysql/data/mysql-bin
socket      = /tmp/mysql.sock
port        = 3306
server-id   = 1
relay_log_purge = 0
binlog_format = row
binlog_cache_size = 1M
log-error = /usr/local/mysql/logs/error.log
slow-query-log-file = /usr/local/mysql/logs/slow.log
pid-file = /usr/local/mysql/mysqld.pid

skip-external-locking
skip-name-resolve
#skip-networking
log-slave-updates
binlog_format = mixed
max_binlog_size = 128M
expire_logs_days = 10

###############################
# FOR Percona 5.6
#extra_port = 3345
gtid-mode = on
enforce_gtid_consistency
#thread_handling=pool-of-threads
#thread_pool_oversubscribe=8
explicit_defaults_for_timestamp

###############################
character-set-server = utf8
slow-query-log
binlog_format = row
max_binlog_size = 128M
binlog_cache_size = 1M
expire-logs-days = 5
back_log = 500
long_query_time = 1
max_connections = 1100
max_user_connections = 1000
max_connect_errors = 1000
wait_timeout = 100
interactive_timeout = 100
connect_timeout = 20
slave-net-timeout = 30
max-relay-log-size = 256M
relay-log = relay-bin
transaction_isolation = READ-COMMITTED
performance_schema = 0
#myisam_recover
key_buffer_size = 64M
max_allowed_packet = 16M
#table_cache = 3096
table_open_cache = 6144
table_definition_cache = 4096
sort_buffer_size = 128K
read_buffer_size = 1M
read_rnd_buffer_size = 1M
join_buffer_size = 128K
myisam_sort_buffer_size = 32M
tmp_table_size = 32M
max_heap_table_size = 64M
query_cache_type = 0
query_cache_size = 0
bulk_insert_buffer_size = 32M
thread_cache_size = 64
#thread_concurrency = 32
thread_stack = 192K
skip-slave-start
# InnoDB
innodb_data_home_dir = /usr/local/mysql/data
innodb_log_group_home_dir = /usr/local/mysql/data
innodb_data_file_path = ibdata1:10M:autoextend
innodb_buffer_pool_size = 500M
innodb_buffer_pool_instances    = 8
#innodb_additional_mem_pool_size = 16M
innodb_log_file_size = 200M
innodb_log_buffer_size = 16M
innodb_log_files_in_group = 3
innodb_flush_log_at_trx_commit = 0
innodb_lock_wait_timeout = 10
innodb_sync_spin_loops = 40
innodb_max_dirty_pages_pct = 90
innodb_support_xa = 0
innodb_thread_concurrency = 0
innodb_thread_sleep_delay = 500
#innodb_file_io_threads    = 4
innodb_concurrency_tickets = 1000
log_bin_trust_function_creators = 1
innodb_flush_method = O_DIRECT
innodb_file_per_table
innodb_read_io_threads = 16
innodb_write_io_threads = 16
innodb_io_capacity = 2000
innodb_file_format = Barracuda
innodb_purge_threads = 1
innodb_purge_batch_size = 32
innodb_old_blocks_pct = 75
innodb_change_buffering = all
innodb_stats_on_metadata = OFF
 
[mysqldump]
quick
max_allowed_packet = 128M
#myisam_max_sort_file_size = 10G
 
[mysql]
no-auto-rehash
max_allowed_packet = 128M
prompt   = '-product-[\u@\h][\d]>'
default_character_set  = utf8
[myisamchk]
key_buffer_size = 64M
sort_buffer_size = 10M
read_buffer = 2M
write_buffer = 2M
 
[mysqld_safe]
log-error = /usr/local/mysql/logs/error.log
pid-file=/usr/local/mysql/mysqld.pid

[mysqlhotcopy]
interactive-timeout
EOF
echo -e "\e[1;34mInit mysql now,please wait...\e[0m"
chmod 777 /usr/local/mysql  #不给权限，初始化报错 如下：
#Can't create/write to file '/usr/local/mysql/ibIGIKvS' (Errcode: 13 - Permission denied)
/usr/local/mysql/scripts/mysql_install_db --basedir=${MDIR} --datadir=${DATADIR} --user=mysql >/dev/null 2>&1
echo 'export PATH=$PATH:/usr/local/mysql/bin'>>/etc/profile && echo "/etc/init.d/mysqld start" >> /etc/rc.d/rc.local
source /etc/profile
\cp ${MDIR}/support-files/mysql.server /etc/init.d/mysqld && chmod +x /etc/init.d/mysqld && chkconfig mysqld  on
#加载动态库
cat >/etc/ld.so.conf.d/mysql.conf<<EOF
    /usr/local/mysql/lib
    /usr/local/lib
EOF
ldconfig
ln -sf /usr/local/mysql/bin/mysql /usr/bin/mysql
ln -sf /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
ln -sf /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk
ln -sf /usr/local/mysql/bin/mysqld_safe /usr/bin/mysqld_safe
ln -sf /usr/local/mysql/bin/mysqlcheck /usr/bin/mysqlcheck
#start mysql
/etc/init.d/mysqld start
#mysql-5.6.x设置密码方法。和mysql-5.7.x不一样
/usr/local/mysql/bin/mysqladmin -uroot password ${mysql_password} >/dev/null  2>&1
;;
 
"mysql-5.7.21")
echo -e "\e[1;34mConfig mysql,please wait...\e[0m"
cd ${DIR} && tar zxf ${MYSQL57_BIN_SOURCE}.tar.gz && cd ${MYSQL57_BIN_SOURCE}/ && \mv ./* /usr/local/mysql 
mkdir -p /usr/local/mysql/logs && chown -R mysql.mysql /usr/local/mysql
[ $? -eq 0 ] && echo  "Mysql install ok ,The next step is init mysql." || echo  -e "\e[1;35mMysql install error ,please check\e[0m"
[ -f "/etc/my.cnf" ] && \mv /etc/my.cnf /etc/my.cnf.bak
cat > /etc/my.cnf  <<EOF
[client]
#password   = your_password
port        = 3306
socket      = /tmp/mysql.sock
 
[mysqld]
port        = 3306
socket      = /tmp/mysql.sock
basedir = /usr/local/mysql
datadir = /usr/local/mysql/data
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
thread_cache_size = 8
query_cache_size = 8M
tmp_table_size = 16M
performance_schema_max_table_instances = 500
 
explicit_defaults_for_timestamp = true
#skip-networking
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535
 
log-bin=/usr/local/mysql/data/mysql-bin
binlog_format=mixed
server-id   = 1
expire_logs_days = 10
early-plugin-load = ""
 
 
default_storage_engine = InnoDB
innodb_file_per_table = 1
innodb_data_home_dir = /usr/local/mysql/data
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = /usr/local/mysql/data
innodb_buffer_pool_size = 16M
innodb_log_file_size = 5M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 50
 
[mysqldump]
quick
max_allowed_packet = 16M
 
[mysql]
no-auto-rehash
 
[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M
 
[mysqlhotcopy]
interactive-timeout
EOF
cd ${MDIR} && mkdir -p ${MDIR}/{data,logs}
chown -R mysql.mysql /usr/local/mysql
chmod 777 /usr/local/mysql
#初始化数据库，登录密码是空的
/usr/local/mysql/bin/mysqld --initialize-insecure --basedir=${MDIR} --datadir=${DATADIR} --user=mysql >/dev/null 2>&1
echo 'export PATH=$PATH:/usr/local/mysql/bin'>>/etc/profile && echo "/etc/init.d/mysqld start" >> /etc/rc.d/rc.local
source /etc/profile
\cp ${MDIR}/support-files/mysql.server /etc/init.d/mysqld && chmod +x /etc/init.d/mysqld && chkconfig mysqld  on
#加载动态库
cat >/etc/ld.so.conf.d/mysql.conf<<EOF
    /usr/local/mysql/lib
    /usr/local/lib
EOF
ldconfig
ln -sf /usr/local/mysql/bin/mysql /usr/bin/mysql
ln -sf /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
ln -sf /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk
ln -sf /usr/local/mysql/bin/mysqld_safe /usr/bin/mysqld_safe
ln -sf /usr/local/mysql/bin/mysqlcheck /usr/bin/mysqlcheck
#start mysql
/etc/init.d/mysqld start
#更改mysql登陆密码
/usr/local/mysql/bin/mysql -e "update mysql.user set authentication_string=password("${mysql_password}") where user='root' and Host = 'localhost';"
/usr/local/mysql/bin/mysql -e "alter user 'root'@'localhost' identified by "${mysql_password}";"
/usr/local/mysql/bin/mysql -uroot -p${mysql_password} -e "flush privileges;"
;;
 
*) 
  echo "Mysql version error,please  check" && exit 1
;;
esac
}
Msgbox

function  mysql_check_status(){
netstat -tunlp | grep  mysqld
if [ $? -eq 0 ];then
	mysql_version=`mysql  -V`
	echo -e "Mysql start  sucess,and  mysql version  is :\n" "\e[1;35m${mysql_version}\e[0m"
	echo -e "Mysql root password is:\t \e[1;35m${mysql_password}\e[0m"
else
	echo -e "\e[1;35mMysql start  failed ,please check\e[0m"
	exit 1;
fi
}
 
function  main(){
checkroot
create_user_mysql
install_required_packages
check_datadir
menu
mysql_version
mysql_download
mysql_install
mysql_check_status
}
main
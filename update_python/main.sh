#!/bin/bash
#升级系统python脚本

sys_version=`cat /etc/redhat-release |grep -Eo "[6,7]\.[0-9]+"|cut -d. -f1`
cpu_processor=`grep "processor" /proc/cpuinfo | wc -l`

echo "your sys version is $sys_version"
echo "your cpu core is $cpu_processor"
install_python_version="2.7.14"
#install_python_version="3.6.4"
SETUPTOOLS="setuptools-38.5.2"
PIP="pip-9.0.1"
DIR=`pwd`
sleep 2
yum -y install gcc gcc-c++ make ntp iptraf tree openssl openssl-devel
yum -y groupinstall "Development tools"
yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel

cd source &&tar -xf Python-$install_python_version.tgz&&cd Python-$install_python_version
./configure --prefix=/usr/local/python$install_python_version --enable-optimizations&&make -j $cpu_processor&&make install
if [ $? -ne 0 ];then
	echo "install error"
	exit 2
fi
mv  /usr/bin/python /usr/bin/python.bak

ln -s /usr/local/python$install_python_version/bin/python`echo "$install_python_version"|awk -F. '{print $1"."$2}'` /usr/bin/python

cd $DIR/source&&unzip $SETUPTOOLS.zip &&cd $SETUPTOOLS
python setup.py install

if [ -f /usr/bin/pip ];then
	rm -f /usr/bin/pip
fi

if [ `echo "$install_python_version"|awk -F. '{print $1}'` -eq 2 ];then
	cd $DIR/source&&tar -xf $PIP.tar.gz &&cd $PIP
	python setup.py install
	
	ln -s /usr/local/python$install_python_version/bin/pip /usr/bin/pip
else
	ln -s /usr/local/python$install_python_version/bin/pip3 /usr/bin/pip
fi
	





case ${sys_version} in
5)
  sed -i 's@\#\!\/usr\/bin\/python@\#\!\/usr\/bin\/python2.4@' /usr/bin/yum
  ;;
6)
  sed -i 's@\#\!\/usr\/bin\/python@\#\!\/usr\/bin\/python2.6@' /usr/bin/yum
  ;;
7)
  sed -i 's@\#\!\/usr\/bin\/python@\#\!\/usr\/bin\/python2.7@' /usr/bin/yum
  sed -i 's@\#\!\/usr\/bin\/python@\#\!\/usr\/bin\/python2.7@' /usr/libexec/urlgrabber-ext-down
  ;;
esac

python -V
pip list


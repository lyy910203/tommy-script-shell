#!/bin/bash
#__Author__:Allen_Jol at 2018-03-26 11:07:29
#Description: upgrade python to 2.7

SYS_VERSION=`cat /etc/redhat-release | egrep -o "[6,7]\.[0-9]+" | cut -d"." -f 1`
CPU_CORE=`grep "processor" /proc/cpuinfo | wc -l`
DIR="/usr/local/src"
SETUPTOOLS_SOURCE="setuptools-39.0.1"
SETUP_DOWN_URL="https://pypi.python.org/packages/72/c2/c09362ab29338413ab687b47dab03bab4a792e2bbb727a1eb5e0a88e3b86/setuptools-39.0.1.zip#md5=75310b72ca0ab4e673bf7679f69d7a62"
PIP_SOURCE="pip-9.0.3"
PIP_DOWN_URL="https://pypi.python.org/packages/c4/44/e6b8056b6c8f2bfd1445cc9990f478930d8e3459e9dbf5b8e2d2922d64d3/pip-9.0.3.tar.gz#md5=b15b33f9aad61f88d0f8c866d16c55d8"
PYTHON_SOURCE="Python-2.7.13"
PYTHON27_DOWN_URL="https://www.python.org/ftp/python/2.7.13/${PYTHON_SOURCE}.tgz"
export PATH=/usr/local/python2.7/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

echo -e "Your sys version is: \e[1;34m${SYS_VERSION}\e[0m"
echo -e "Your cpu core is: \e[1;34m${CPU_CORE}\e[0m"
sleep 3

function check_root(){
  if [ $UID -ne 0 ];then
    echo -e "\e[1;35mMust be root to excute this script.\e[0m"
    exit 1
  fi
}

function install_required_packages(){
  NETSTAT=`ping -c 1 www.baidu.com >>/dev/null`
  if [ $? -eq 0 ];then
    echo -e "Install required packages,please wait...\t Or you can press \e[5;35m[ctrl+c]\e[0m to exit."
    yum -y install gcc gcc-c++ make unzip lrzsz wget gcc* zlib zlib-devel openssl openssl-devel ncurses-devel  bzip2-devel sqlite-devel python-devel
  else
    echo -e "\e[1;35mnetwork is error,please check first.\e[0m"
    exit 1
  fi
}

function python_download(){
  if [ -f "${DIR}/${PYTHON_SOURCE}" ];then
    echo "There have python dir,scripts have been locked.make sure you don't upgrade python first."
    exit 1
  else
    cd ${DIR} || mkdir -p ${DIR} && cd ${DIR}
    echo -e "mDownload \e[1;34m${PYTHON_SOURCE}.tgz\e[0m and config it now,please wait for a moment!"
    wget -c ${PYTHON27_DOWN_URL} && tar -zxf ${PYTHON_SOURCE}.tgz
    cd ${DIR}/${PYTHON_SOURCE}
    ./configure --prefix=/usr/local/python2.7 >>/dev/null
    if [ $? -eq 0 ];then
      make -j ${CPU_CORE} >>/dev/null && make install >>/dev/null
      grep -q '/usr/local/python2.7/bin' /etc/profile || echo 'export PATH=/usr/local/python2.7/bin:$PATH'>>/etc/profile
      source /etc/profile
      \mv /usr/bin/python /usr/bin/pythonbak
      ln -fs /usr/local/python2.7/bin/python2.7 /usr/bin/python
    else
      echo "Configure python error,please check..."
    fi
  fi
}

case ${SYS_VERSION} in
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

function setuptools_download(){
  cd ${DIR} || mkdir -p ${DIR} && cd ${DIR} && wget -c ${SETUP_DOWN_URL} && unzip ${SETUPTOOLS_SOURCE}.zip
  cd ${DIR}/${SETUPTOOLS_SOURCE} && python setup.py install
  [ $? -ne 0 ] && echo -e "\e[1;35mconfig setuptools error,please check..."
}

function pip_download(){
  cd ${DIR} || mkdir -p ${DIR} && cd ${DIR} && wget -c ${PIP_DOWN_URL} && tar -zxf ${PIP_SOURCE}.tar.gz
  cd ${DIR}/${PIP_SOURCE} && python setup.py install
  [ $? -ne 0 ] && echo -e "\e[1;35mconfig pip error,please check..."
}

function main(){
  check_root
  install_required_packages
  python_download
  setuptools_download
  pip_download
}
main

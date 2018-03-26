#!/bin/bash
#__Author__:Allen_Jol at 2018-03-26 23:42:45
#Description: 利用pip安装supervisor。前提一定要安装好python2.x（目前supervisor不支持python3.x），pip

SUPERVISOR_PATH="/etc/supervisor/conf.d"

function check_root(){
  if [ $UID -ne 0 ];then
    echo -e "\e[1;35mMust be root to excute this script.\e[0m"
    exit 1
  fi
}
check_root

function supervisor_install(){
  PIP=`pip -V | awk '{print $1"-"$2}' | wc -l`
  if [ $PIP -eq 0 ];then
    echo "please install pip first" && exit 1
  else
      if [ -f "${SUPERVISOR_PATH}" ];then
        echo "There have supervisor in ${SUPERVISOR_PATH},please check first..."
        exit 1
      else
        pip install supervisor
        /usr/local/python2.7/bin/echo_supervisord_conf > /etc/supervisord.conf
        mkdir -p /etc/supervisor/conf.d/
        sed -i 's@\;\[include\]@\[include\]@g' /etc/supervisord.conf
        sed -i 's@\;files \= relative\/directory\/\*\.ini@files \= \/etc\/supervisor\/conf.d\/\*\.conf@g' /etc/supervisord.conf
        /usr/local/python2.7/bin/supervisord -c /etc/supervisord.conf
      fi
    echo "supervisor install successfull."
  fi
}
supervisor_install

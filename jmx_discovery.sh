#!/bin/bash
t_datadir=`ps -ef | grep [t]omcat | grep hsj |  awk '{print $9}'| awk -F"=|conf" '{print $3}'`
tomcat_no=`ps -ef | grep [t]omcat | grep hsj |  awk '{print $9}'| awk -F"=|conf" '{print $3}'|wc -l`
i=1
printf '{"data":[\n'

for tomcat in $t_datadir
do
    t_service=`echo "$tomcat"|awk -F"/" '{print $(NF-1)}'`
    n_port=`cat "$tomcat"bin/catalina.sh |grep 655 |awk -F"=" '{print $(NF+1-1)}'`
    if [ "$i" != ${tomcat_no} ];then
        printf "\t\t{ \n"
        printf "\t\t\t\"{#JMX_PORT}\":\"${n_port},\n"
        printf "\t\t\t\"{#JAVA_NAME}\":\"${t_service}\"},\n"

    else
        printf "\t\t{ \n"
        printf "\t\t\t\"{#JMX_PORT}\":\"${n_port},\n"
        printf "\t\t\t\"{#JAVA_NAME}\":\"${t_service}\"}]}\n"
    fi
    let "n_port=n_potr+1"
    let "i=i+1"
done

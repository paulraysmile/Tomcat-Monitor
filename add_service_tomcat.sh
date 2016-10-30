#!/bin/bash
cp /home/monitor/jmx_discovery_bak.sh /home/zabbix/jmx_discovery.sh
cp /home/monitor/cmdline-jmxclient-0.10.3.jar /lib/cmdline-jmxclient-0.10.3.jar
chmod +x /home/zabbix/jmx_discovery.sh

t_datadir=`ps -ef | grep [t]omcat | grep monitor | awk '{print $9}'| awk -F"=|conf" '{print $3}'`
tomcat_no=`ps -ef | grep [t]omcat | grep monitor | awk '{print $9}'| awk -F"=|conf" '{print $3}'|wc -l`
n_port=12345
local_ip=`ifconfig eth0 |awk -F '[ :]+' 'NR==2 {print $4}'`
for tomcat in $t_datadir
do
    m_no=`cat -n $tomcat/bin/catalina.sh | grep 'Execute The Requested Command' | awk '{print $1}'`
    cp $tomcat/bin/catalina.sh  $tomcat/bin/catalina.sh_bak
    cp /home/monitor/catalina-jmx-remote.jar  $tomcat/lib/catalina-jmx-remote.jar
    sed -i ''$m_no'a export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote"'  $tomcat/bin/catalina.sh
    let "m_no=m_no+1"
    sed -i ''$m_no'a export CATALINA_OPTS="$CATALINA_OPTS -Djava.rmi.server.hostname='$local_ip'"' $tomcat/bin/catalina.sh
    let "m_no=m_no+1"
    sed -i ''$m_no'a export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote.port='$n_port'"' $tomcat/bin/catalina.sh
    let "m_no=m_no+1"
    sed -i ''$m_no'a export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote.ssl=false"' $tomcat/bin/catalina.sh
    let "m_no=m_no+1"
    sed -i ''$m_no'a export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote.authenticate=false"' $tomcat/bin/catalina.sh
    let "n_port=n_port+1"
done

local_ip=`ifconfig eth0 |awk -F '[ :]+' 'NR==2 {print $4}'`
cat >> /etc/zabbix/zabbix_agentd.conf <<END
UserParameter=java.jmx.discovery,/home/zabbix/jmx_discovery.sh
UserParameter=java.Runtime.status[*],/usr/bin/java -jar /lib/cmdline-jmxclient-0.10.3.jar - $local_ip:\$1 java.lang:type=Runtime \$2 2>&1 |grep \$2 |awk '{print \$NF}'
UserParameter=java.Memory.status[*],/usr/bin/java -jar /lib/cmdline-jmxclient-0.10.3.jar - $local_ip:\$1 java.lang:type=Memory \$2 2>&1 |grep \$2 |awk '{print \$NF}'
UserParameter=java.System.status[*],/usr/bin/java -jar /lib/cmdline-jmxclient-0.10.3.jar - $local_ip:\$1 java.lang:type=OperatingSystem \$2 2>&1 |grep \$2 |awk '{print \$NF}'
UserParameter=java.HeapMemoryUsage.status[*],/usr/bin/java -jar /lib/cmdline-jmxclient-0.10.3.jar - $local_ip:\$1 java.lang:type=Memory HeapMemoryUsage 2>&1 |grep \$2 |awk '{print \$NF}'
UserParameter=java.NonHeapMemoryUsage.status[*],/usr/bin/java -jar /lib/cmdline-jmxclient-0.10.3.jar - $local_ip:\$1 java.lang:type=Memory NonHeapMemoryUsage 2>&1 |grep \$2 |awk '{print \$NF}'
UserParameter=java.LoadClass.status[*],/usr/bin/java -jar /lib/cmdline-jmxclient-0.10.3.jar - $local_ip:\$1 java.lang:type=ClassLoading \$2 2>&1 |awk '{print \$NF}'
UserParameter=java.Threading.status[*],/usr/bin/java -jar /lib/cmdline-jmxclient-0.10.3.jar - $local_ip:\$1 java.lang:type=Threading \$2 2>&1 |awk '{print \$NF}'
END


#service zabbix_agentd restart



#!/bin/sh 
MYSQL_SOCK="/tmp/mysql.sock" 
MYSQL_PWD=`cat /opt/application/zabbix/plugin/.mysqlp` 
ARGS=1 
if [ $# -ne "$ARGS" ];then 
    echo "Please input one arguement:" 
fi 
case $1 in 
    Uptime) 
        result=`mysqladmin -uZabbixAgent -p${MYSQL_PWD} -S $MYSQL_SOCK status|cut -f2 -d":"|cut -f1 -d"T"` 
            echo $result 
            ;; 
    Com_update) 
        result=`mysqladmin -uZabbixAgent -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status |grep -w "Com_update"|cut -d"|" -f3` 
        echo $result 
            ;; 
    Slow_queries) 
    	 result=`mysqladmin -uZabbixAgent -p${MYSQL_PWD} -S $MYSQL_SOCK status |cut -f5 -d":"|cut -f1 -d"O"` 
         echo $result 
         ;; 
    Com_select) 
        result=`mysqladmin -uZabbixAgent -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status |grep -w "Com_select"|cut -d"|" -f3` 
        echo $result 
        ;; 
    Com_rollback) 
        result=`mysqladmin -uZabbixAgent -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status |grep -w "Com_rollback"|cut -d"|" -f3` 
        echo $result 
        ;; 
    Questions) 
        result=`mysqladmin -uZabbixAgent -p${MYSQL_PWD} -S $MYSQL_SOCK status|cut -f4 -d":"|cut -f1 -d"S"` 
        echo $result 
        ;; 
    Com_insert) 
        result=`mysqladmin -uZabbixAgent -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status |grep -w "Com_insert"|cut -d"|" -f3` 
        echo $result 
        ;; 
    Com_delete) 
        result=`mysqladmin -uZabbixAgent -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status |grep -w "Com_delete"|cut -d"|" -f3` 
        echo $result 
        ;; 
    Com_commit) 
        result=`mysqladmin -uZabbixAgent -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status |grep -w "Com_commit"|cut -d"|" -f3` 
        echo $result 
        ;; 
    Bytes_sent) 
        result=`mysqladmin -uZabbixAgent -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status |grep -w "Bytes_sent" |cut -d"|" -f3` 
        echo $result 
        ;; 
    Bytes_received) 
        result=`mysqladmin -uZabbixAgent -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status |grep -w "Bytes_received" |cut -d"|" -f3` 
        echo $result 
        ;; 
    Com_begin) 
        result=`mysqladmin -uZabbixAgent -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status |grep -w "Com_begin"|cut -d"|" -f3` 
        echo $result 
        ;; 
    CPU_usage)
	result=`/usr/bin/top -bn1 -U mysql|grep mysqld|awk '{print $9}'`
	echo $result
	;;
    Memory_usage)
	result=`/usr/bin/top -bn1 -U mysql|grep mysqld|awk '{print $10}'`
	echo $result
	;;
                        
        *) 
    echo "Usage:$0(Uptime|Com_update|Slow_queries|Com_select|Com_rollback|Questions|CPU_usage|Memory_usage)" 
        ;; 
esac
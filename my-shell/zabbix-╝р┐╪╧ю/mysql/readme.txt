在zabbix_agent.conf添加如下代码

# 获取mysql性能指标,这个是上面定义好的脚本
UserParameter=mysql.status[*],/opt/application/zabbix/plugin/Check_mysql.sh $1
# # 获取mysql运行状态
UserParameter=mysql.ping,mysqladmin -uUSER -pPASSWPRD ping | grep -c alive
重启 zabbix-agent 即可
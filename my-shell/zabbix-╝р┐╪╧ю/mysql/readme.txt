��zabbix_agent.conf������´���

# ��ȡmysql����ָ��,��������涨��õĽű�
UserParameter=mysql.status[*],/opt/application/zabbix/plugin/Check_mysql.sh $1
# # ��ȡmysql����״̬
UserParameter=mysql.ping,mysqladmin -uUSER -pPASSWPRD ping | grep -c alive
���� zabbix-agent ����
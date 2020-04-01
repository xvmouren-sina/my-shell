/*********************************nginx配置*********************************************/
查看有没有需要的模块–with-http_stub_status_module，需要单独安装一下。
参考：https://www.cnblogs.com/huangyanqi/p/8527805.html

配置站点文件添加如下location模块：
location = /nginx_status {
          stub_status  on;
          access_log   off;
          allow 127.0.0.1;
          deny all;

# nginx -s reload
[root@nginx ~]# curl http://127.0.0.1/nginx-status
Active connections: 1
server accepts handled requests
 4 4 4
Reading: 0 Writing: 1 Waiting: 0


/**********************************脚本配置*************************************************/
# vim /etc/zabbix/nginx_status.sh
脚本添加x权限

在zabbix_agentd .conf 添加如下代码（或者/etc/zabbix/zabbix_agentd.d/nginx.conf）
注意脚本路径
UserParameter=Nginx.Status[*],/etc/zabbix/nginx_status.sh $1
测试，不行就zabbix-agent重启即可
# zabbix_get -s nginx-ip -k Nginx.Status[ping]

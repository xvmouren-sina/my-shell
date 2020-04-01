#!/bin/bash
# Info: zabbix 监控 nginx 性能以及进程状态

# 检查nginx 进程是否存在
function ping {
  /sbin/pidof nginx | wc -l
}

# 检查nginx 性能
# 活动连接数
function active {
    /usr/bin/curl "http://127.0.0.1/nginx_status/" 2>/dev/null| grep 'Active' | awk '{print $NF}'
}
# 处理的连接数
function accepts {
    /usr/bin/curl "http://127.0.0.1/nginx_status/" 2>/dev/null| awk NR==3 | awk '{print $1}'
}
# 成功创建的握手次数
function handled {
    /usr/bin/curl "http://127.0.0.1/nginx_status/" 2>/dev/null| awk NR==3 | awk '{print $2}'
}
# 处理的请求数
function requests {
    /usr/bin/curl "http://127.0.0.1/nginx_status/" 2>/dev/null| awk NR==3 | awk '{print $3}'
}
# 读取客户端的连接数
function reading {
    /usr/bin/curl "http://127.0.0.1/nginx_status/" 2>/dev/null| grep 'Reading' | awk '{print $2}'
}
# 响应数据到客户端的数量
function writing {
    /usr/bin/curl "http://127.0.0.1/nginx_status/" 2>/dev/null| grep 'Writing' | awk '{print $4}'
}
# 已经处理完正在等候下一次请求指令的驻留连接
function waiting {
    /usr/bin/curl "http://127.0.0.1/nginx_status/" 2>/dev/null| grep 'Waiting' | awk '{print $6}'
}
# 执行function
$1
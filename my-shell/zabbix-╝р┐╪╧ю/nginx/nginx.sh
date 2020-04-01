#!/bin/bash
# Info: zabbix ��� nginx �����Լ�����״̬

# ���nginx �����Ƿ����
function ping {
  /sbin/pidof nginx | wc -l
}

# ���nginx ����
# �������
function active {
    /usr/bin/curl "http://127.0.0.1/nginx_status/" 2>/dev/null| grep 'Active' | awk '{print $NF}'
}
# �����������
function accepts {
    /usr/bin/curl "http://127.0.0.1/nginx_status/" 2>/dev/null| awk NR==3 | awk '{print $1}'
}
# �ɹ����������ִ���
function handled {
    /usr/bin/curl "http://127.0.0.1/nginx_status/" 2>/dev/null| awk NR==3 | awk '{print $2}'
}
# �����������
function requests {
    /usr/bin/curl "http://127.0.0.1/nginx_status/" 2>/dev/null| awk NR==3 | awk '{print $3}'
}
# ��ȡ�ͻ��˵�������
function reading {
    /usr/bin/curl "http://127.0.0.1/nginx_status/" 2>/dev/null| grep 'Reading' | awk '{print $2}'
}
# ��Ӧ���ݵ��ͻ��˵�����
function writing {
    /usr/bin/curl "http://127.0.0.1/nginx_status/" 2>/dev/null| grep 'Writing' | awk '{print $4}'
}
# �Ѿ����������ڵȺ���һ������ָ���פ������
function waiting {
    /usr/bin/curl "http://127.0.0.1/nginx_status/" 2>/dev/null| grep 'Waiting' | awk '{print $6}'
}
# ִ��function
$1